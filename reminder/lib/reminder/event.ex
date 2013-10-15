defmodule Reminder.Event do
  @timeout_limit 49 * 24 * 60 * 60

  defrecord State, server: nil, name: nil, remaining_seconds: 0

  def start(name, delay), do: spawn(__MODULE__, :init, [ self, name, delay ])
  def start_link(name, delay), do: spawn_link(__MODULE__, :init, [ self, name, delay ])

  def init(server, name, delay) do
    loop(State.new(server: server, name: name, remaining_seconds: normalize(delay)))
  end
  defp normalize(seconds) do
    [ rem(seconds, @timeout_limit) | List.duplicate(@timeout_limit, div(seconds, @timeout_limit)) ]
  end

  def cancel(pid) do
    reference = :erlang.monitor(:process, pid)
    pid <- { self, reference, :cancel }
    receive do
      { ^reference, :ok } -> :erlang.demonitor(reference, [ :flush ]) && :ok
      { :DOWN, ^reference, :process, ^pid, _reason } -> :ok
    end
  end

  defp loop(state = State[server: server, remaining_seconds: [ seconds | more_seconds ]]) do
    receive do
      { server, reference, :cancel } ->
        server <- { reference, :ok }
    after
      seconds * 1_000 ->
        if more_seconds === [] do
          server <- { :done, state.name }
        else
          loop(state[remaining_seconds: more_seconds])
        end
    end
  end
end
