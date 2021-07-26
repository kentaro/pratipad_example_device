# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
import Config

# Enable the Nerves integration with Mix
Application.start(:nerves_bootstrap)

# Customize non-Elixir parts of the firmware. See
# https://hexdocs.pm/nerves/advanced-configuration.html for details.

config :nerves, :firmware, rootfs_overlay: "rootfs_overlay"

# Set the SOURCE_DATE_EPOCH date for reproducible builds.
# See https://reproducible-builds.org/docs/source-date-epoch/ for more information

config :nerves, source_date_epoch: "1626600144"

# Use Ringlogger as the logger backend and remove :console.
# See https://hexdocs.pm/ring_logger/readme.html for more information on
# configuring ring_logger.

config :logger, backends: [RingLogger]

if Mix.target() == :host or Mix.target() == :"" do
  import_config "host.exs"
else
  import_config "target.exs"
end

# Configurations for this project
config :pratipad_example_device,
  target: Mix.target(),
  device_name: System.get_env("PRATIPAD_DEVICE"),
  cookie: "pratipad_cookie",
  dataflow: "dataflow@dataflow.pratipad.local",
  led_pin: 17

config :nerves_time_zones,
  data_dir: "./tmp/nerves_time_zones",
  default_time_zone: "Asia/Tokyo"
