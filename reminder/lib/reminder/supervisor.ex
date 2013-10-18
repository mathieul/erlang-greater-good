defmodule Reminder.Supervisor do
  def start(module, arguments) do
    spawn(__MODULE__, :init, [ { module, arguments } ])
  end

  def start_link(module, arguments) do
    spawn_link(__MODULE__, :init, [ { module, arguments } ])
  end

  def init({ module, arguments }) do
    Process.flag(:trap_exit, true)
    loop({ module, :start_link, arguments })
  end

  def loop({ module, function, arguments }) do
    pid = apply(module, function, arguments)
    receive do
      { :EXIT, _from, :shutdown } -> exit(:shutdown)
      { :EXIT, pid, reason } ->
        IO.puts "Process #{inspect pid} exited for reason #{inspect reason}"
        loop({ module, function, arguments })
    end
  end
end
