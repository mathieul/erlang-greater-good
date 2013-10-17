defmodule Reminder.Event do
  @timeout_limit 49 * 24 * 60 * 60

  defrecord State, server: nil,
                   name: nil,
                   to_go: 0

  def start(name, date_time), do: spawn(__MODULE__, :init, [ self, name, date_time ])
  def start_link(name, date_time), do: spawn_link(__MODULE__, :init, [ self, name, date_time ])

  def init(server, name, date_time) do
    loop(State.new(server: server, name: name, to_go: time_to_go(date_time)))
  end

  defp normalize(seconds) do
    [ rem(seconds, @timeout_limit) | List.duplicate(@timeout_limit, div(seconds, @timeout_limit)) ]
  end

  defp time_to_go(date_time = { { _, _, _ }, { _, _, _ } }) do
    now = :calendar.local_time
    to_go = :calendar.datetime_to_gregorian_seconds(date_time) -
            :calendar.datetime_to_gregorian_seconds(now)
    remaining_seconds = if to_go > 0, do: to_go, else: 0
    normalize(remaining_seconds)
  end

  def cancel(pid) do
    reference = :erlang.monitor(:process, pid)
    pid <- { self, reference, :cancel }
    receive do
      { ^reference, :ok } -> :erlang.demonitor(reference, [ :flush ]) && :ok
      { :DOWN, ^reference, :process, ^pid, _reason } -> :ok
    end
  end

  defp loop(state = State[server: server, to_go: [ seconds | more_seconds ]]) do
    receive do
      { server, reference, :cancel } ->
        server <- { reference, :ok }
    after
      seconds * 1_000 ->
        if more_seconds === [] do
          server <- { :done, state.name }
        else
          loop(state[to_go: more_seconds])
        end
    end
  end
end
