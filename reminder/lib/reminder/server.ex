defmodule Reminder.Server do
  defrecord State, events: [],
                   clients: []

  defrecord Event, name: nil,
                   description: nil,
                   pid: nil,
                   date_time: { { 1970, 1, 1 }, { 0, 0, 0 } }

  def init do
    loop(State[events: ListDict.new, clients: ListDict.new])
  end

  defp loop(state = State[]) do
    receive do
      { pid, msg_reference, { :subscribe, client } } ->
        reference = :erlang.monitor(:process, client)
        pid <- { msg_reference, :ok }
        loop(state[clients: Dict.put(state.client, reference, client)])

      { pid, msg_reference, { :add, name, description, date_time } } ->
        if Reminder.DateTime.valid?(date_time) do
          event_pid = Reminder.Event.start_link(name, date_time)
          event = Event.new name: name,
                     description: description,
                             pid: event_pid,
                       date_time: date_time
          pid <- { msg_reference, :ok }
          loop(state[events: Dict.put(state.events, name, event)])
        else
          pid <- { msg_reference, { :error, :bad_date_time }}
          loop(state)
        end

      { pid, msg_reference, { :cancel, name } } ->
        events = case Dict.get(state.events, name) do
          { :ok, event } ->
            Reminder.Event.cancel(event.pid)
            Dict.delete(state.events, name)
          :error ->
            state.events
        end
        pid <- { msg_reference, :ok }
        loop(state[events: events])

      { :done, name } ->
        case Dict.get(state.events, name) do
          { :ok, event } ->
            send_to_clients(state.clients, { :done, event.name, event.description })
            loop(state[events: Dict.delete(state.events, name)])
          :error ->
            loop(state)
        end

      :shutdown ->
        exit(:shutdown)

      { :DOWN, msg_reference, :process, _pid, _reason } ->
        loop(state[clients: Dict.delete(state.clients, msg_reference)])

      :code_change ->
        __MODULE__.loop(state)

      unknown ->
        IO.puts "Unknown message: #{inspect unknown}"
        loop(state)
    end
  end

  defp send_to_clients(clients, message) do
    Enum.each clients, fn _ref, pid ->
      pid <- message
    end
  end
end
