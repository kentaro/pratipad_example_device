defmodule Pratipad.Example.Device.Worker do
  use GenServer

  @default_interval 60 * 1_000

  @impl GenServer
  def init(opts \\ []) do
    {:ok, bme280} = BMP280.start_link(bus_name: "i2c-1", bus_address: 0x76)
    {:ok, mhz19} = MhZ19.start_link()
    {:ok, device_id} = :inet.gethostname()

    interval = opts[:interval] || @default_interval
    schedule(0)

    {:ok,
     %{
       bme280: bme280,
       mhz19: mhz19,
       interval: interval,
       device_id: to_string(device_id)
     }}
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl GenServer
  def handle_call(:measure, _from, state) do
    result = measure(state)
    {:reply, result, state}
  end

  @impl GenServer
  def handle_cast(:notify, state) do
    GenServer.cast(Pratipad.Example.Device.Led, :blink_for_a_while)
    {:noreply, state}
  end

  @impl GenServer
  def handle_info(:push_message, state) do
    push_message()
    schedule(state.interval)
    {:noreply, state}
  end

  defp schedule(interval) do
    Process.send_after(self(), :push_message, interval)
  end

  defp push_message() do
    GenServer.cast(Pratipad.Example.Device.Client, :push_message)
  end

  defp measure(state) do
    {:ok, bme280_result} = BMP280.measure(state.bme280)
    {:ok, mhz19_result} = MhZ19.measure(state.mhz19)

    %{
      humidity_rh: bme280_result.humidity_rh,
      pressure_pa: bme280_result.pressure_pa,
      temperature_c: bme280_result.temperature_c,
      co2_concentration: mhz19_result.co2_concentration,
      measured_at: NaiveDateTime.local_now(),
      device_id: state.device_id
    }
  end
end
