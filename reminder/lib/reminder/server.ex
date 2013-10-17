defmodule Reminder.Server do
  defrecord State, events: [],
                   clients: []

  defrecord Event, name: nil,
                   description: nil,
                   pid: nil,
                   timeout: { { 1970, 1, 1 }, { 0, 0, 0 } }

  def init do
    loop(State[events: ListDict.new, clients: ListDict.new])
  end

  defp loop(state = State[]) do
    receive do
      { pid, msg_reference, { :subscribe, client } } ->
        reference = :erlang.monitor(:process, client)
        pid <- { msg_reference, :ok }
        loop(state[clients: Dict.put(state.client, reference, client)])

      { pid, msg_reference, { :add, name, description, timeout } } -> raise "TODO"
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
