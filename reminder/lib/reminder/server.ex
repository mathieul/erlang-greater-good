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

      { pid, msg_reference, { :cancel, name } } -> raise "TODO"
      :shutdown -> raise "TODO"
      { :DOWN, msg_reference, :process, _pid, _reason } -> raise "TODO"
      :code_change -> raise "TODO"
      unknown ->
        IO.puts "Unknown message: #{inspect unknown}"
        loop(state)
    end
  end
end
