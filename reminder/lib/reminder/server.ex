defmodule Reminder.Server do
  defrecord State, events: [],
                   clients: []

  defrecord Event, name: nil,
                   description: nil,
                   pid: nil,
                   date_time: { { 1970, 1, 1 }, { 0, 0, 0 } }

  #
  # Public API
  #
  def start do
    :erlang.register(__MODULE__, pid = spawn(__MODULE__, :init, []))
    pid
  end

  def start_link do
    :erlang.register(__MODULE__, pid = spawn_link(__MODULE__, :init, []))
    pid
  end

  def terminate do
    __MODULE__ <- :shutdown
  end

  def subscribe(pid) do
    reference = :erlang.monitor(:process, Process.whereis(__MODULE__))
    __MODULE__ <- { self, reference, { :subscribe, pid }}
    receive do
      { ^reference, :ok } -> { :ok, reference }
      { :DOWN, ^reference, :process, _pid, reason } -> { :error, reason }
    after 500 ->
      { :error, :timeout }
    end
  end

  def add_event(name, description, date_time) do
    reference = make_ref
    __MODULE__ <- { self, reference, { :add, name, description, date_time } }
    receive do
      { ^reference, message } -> message
    after 5000 ->
      { :error, :timeout }
    end
  end

  #
  # Server
  #
  def init do
    loop(State[events: ListDict.new, clients: ListDict.new])
  end

  defp loop(state = State[]) do
    receive do
      { pid, msg_reference, { :subscribe, client } } ->
        reference = :erlang.monitor(:process, client)
        pid <- { msg_reference, :ok }
        clients = Dict.put(state.clients, reference, client)
        loop(state.update(clients: clients))

      { pid, msg_reference, { :add, name, description, date_time } } ->
        if Reminder.DateTime.valid?(date_time) do
          event_pid = Reminder.Event.start_link(name, date_time)
          event = Event.new name: name,
                     description: description,
                             pid: event_pid,
                       date_time: date_time
          pid <- { msg_reference, :ok }
          events = Dict.put(state.events, name, event)
          loop(state.update(events: events))
        else
          pid <- { msg_reference, { :error, :bad_date_time }}
          loop(state)
        end

      { pid, msg_reference, { :cancel, name } } ->
        events = case Dict.fetch(state.events, name) do
          { :ok, event } ->
            Reminder.Event.cancel(event.pid)
            Dict.delete(state.events, name)
          :error ->
            state.events
        end
        pid <- { msg_reference, :ok }
        loop(state.update(events: events))

      { :done, name } ->
        case Dict.fetch(state.events, name) do
          { :ok, event } ->
            send_to_clients(state.clients, { :done, event.name, event.description })
            events = Dict.delete(state.events, name)
            loop(state.update(events: events))
          :error ->
            loop(state)
        end

      :shutdown ->
        exit(:shutdown)

      { :DOWN, msg_reference, :process, _pid, _reason } ->
        clients = Dict.delete(state.clients, msg_reference)
        loop(state.update(clients: clients))

      :code_change ->
        __MODULE__.loop(state)

      unknown ->
        IO.puts "Unknown message: #{inspect unknown}"
        loop(state)
    end
  end

  defp send_to_clients(clients, message) do
    Enum.each clients, fn { _ref, pid } ->
      pid <- message
    end
  end
end
