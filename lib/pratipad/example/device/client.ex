defmodule Pratipad.Example.Device.Client do
  use Pratipad.Client, mode: :demand, backward_enabled: true
  alias Pratipad.Client.{Demand, Backward}

  @impl Demand
  def pull_message() do
    GenServer.call(Pratipad.Example.Device.Worker, :measure)
  end

  @impl Backward
  def backward_message(message) do
    Logger.info("backward_message: #{inspect(message)}")

    if is_atom(message.data) && message.data == :open_the_door do
      GenServer.cast(Pratipad.Example.Device.Worker, :notify)
    end
  end
end
