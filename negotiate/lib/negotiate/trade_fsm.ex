defmodule Negotiate.TradeFsm do
  use GenFSM.Behaviour

  @trade_timeout 30 * 1_000

  #
  # Public API
  #
  def start_link(name) do
    :gen_fsm.start_link(__MODULE__, [ name ], [])
  end

  def trade(own_pid, other_pid) do
    :gen_fsm.send_event(own_pid, { :negotiate, other_pid }, @trade_timeout)
  end

  def accept_trade(own_pid) do
    :gen_fsm.sync_send_event(own_pid, :accept_negotiate)
  end

  def make_offer(own_pid, item) do
    :gen_fsm.send_event(own_pid, { :make_offer, item })
  end

  def retract_offer(own_pid, item) do
    :gen_fsm.send_event(own_pid, { :retract_offer, item })
  end

  def ready(own_pid) do
    :gen_fsm.sync_send_event(own_pid, :ready, :infinity)
  end

  def cancel(own_pid) do
    :gen_fsm.sync_send_all_state_event(own_pid, :cancel)
  end

  #
  # FSM to FSM functions
  #
  def ask_negotiate(other_pid, own_pid) do
    :gen_fsm.send_event(other_pid, { :ask_negotiate, own_pid })
  end

  def accept_negotiate(other_pid, own_pid) do
    :gen_fsm.send_event(other_pid, { :accept_negotiate, own_pid })
  end

  def do_offer(other_pid, item) do
    :gen_fsm.send_event(other_pid, { :do_offer, item })
  end

  def undo_offer(other_pid, item) do
    :gen_fsm.send_event(other_pid, { :undo_offer, item })
  end

  def are_you_ready(other_pid) do
    :gen_fsm.send_event(other_pid, :are_you_ready)
  end

  def am_ready(other_pid) do
    :gen_fsm.send_event(other_pid, :am_ready!)
  end

  def not_yet(other_pid) do
    :gen_fsm.send_event(other_pid, :not_yet)
  end

  def ack_trans(other_pid) do
    :gen_fsm.send_event(other_pid, :ack)
  end

  def ask_commit(other_pid) do
    :gen_fsm.sync_send_event(other_pid, :ask_commit)
  end

  def do_commit(other_pid) do
    :gen_fsm.sync_send_event(other_pid, :do_commit)
  end

  def notify_cancel(other_pid) do
    :gen_fsm.sync_send_all_state_event(other_pid, :cancel)
  end

  #
  # State Machine
  #
  defrecord State, name: "",
                  other: nil,
              own_items: [],
            other_items: [],
                monitor: nil,
                   from: nil

  def init(name) do
    { :ok, :idle, State.new(name: name) }
  end
end
