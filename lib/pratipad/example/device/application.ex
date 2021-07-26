defmodule Pratipad.Example.Device.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: Pratipad.Example.Device.Supervisor]

    children = [] ++ children(target())

    Supervisor.start_link(children, opts)
  end

  def children(:host) do
    []
  end

  def children(_target) do
    device_name = Application.fetch_env!(:pratipad_example_device, :device_name)
    cookie = Application.fetch_env!(:pratipad_example_device, :cookie)
    dataflow = Application.fetch_env!(:pratipad_example_device, :dataflow)

    [
      {Bootexineris, [device_name, cookie, dataflow]},
      {Pratipad.Example.Device.Client,
       [
         name: :pratipad_example_device,
         forwarder_name: :pratipad_forwarder_input,
         backwarder_name: :pratipad_backwarder_output,
         max_retry_count: :infinity
       ]},
      {Pratipad.Example.Device.Worker, [interval: 60 * 1000]},
      {Pratipad.Example.Device.Led, [led_pin: Application.fetch_env!(:pratipad_example_device, :led_pin)]}
    ]
  end

  def target() do
    Application.get_env(:pratipad_example_device, :target)
  end
end
