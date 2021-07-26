defmodule Pratipad.Example.Device.Led do
  use GenServer
  require Logger
  alias Circuits.GPIO

  @default_led_pin 17
  @default_repeat_count 5

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl GenServer
  def init(opts \\ []) do
    repeat_count = opts[:repeat_count] || @default_repeat_count
    led_pin = opts[:led_pin] || @default_led_pin

    Logger.debug("Starting pin #{led_pin} as output")
    {:ok, led} = GPIO.open(led_pin, :output)

    {:ok,
     %{
       repeat_count: repeat_count,
       led_pin: led_pin,
       led: led
     }}
  end

  @impl GenServer
  def handle_cast(:blink_for_a_while, state) do
    repeat_blink(state, state.repeat_count)
    {:noreply, state}
  end

  @impl GenServer
  def handle_cast(:turn_on, state) do
    Logger.debug("Turning LED at #{state.led_pin} ON")
    GPIO.write(state.led, 1)
    {:noreply, state}
  end

  @impl GenServer
  def handle_cast(:turn_off, state) do
    Logger.debug("Turning LED at #{state.led_pin} OFF")
    GPIO.write(state.led, 0)
    {:noreply, state}
  end

  defp repeat_blink(state, repeat_count) do
    if repeat_count > 0 do
      GPIO.write(state.led, 1)
      Process.sleep(500)
      GPIO.write(state.led, 0)
      Process.sleep(500)
      repeat_blink(state, repeat_count - 1)
    end
  end
end
