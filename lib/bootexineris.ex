# This module is borrowed from the article below:
# nerves_pack（vintage_net含む）を使ってNerves起動時に`Node.connect()`するようにした - Qiita https://qiita.com/nishiuchikazuma/items/f68d2661959197d0765c

defmodule Bootexineris do
  use GenServer
  require Logger

  @interval_init_ms 1_000
  @interval_wakeup_ms 1_000
  @interval_alive_ms 60_000
  @interval_alive_false_ms 1_000

  def start_link(node_option \\ []) do
    # to init/1
    GenServer.start_link(__MODULE__, node_option, name: __MODULE__)
  end

  def init(node_option) do
    set_interval(:init, @interval_init_ms)
    {:ok, node_option}
  end

  def set_interval(msg, ms) do
    # to handle_info/2
    Process.send_after(self(), msg, ms)
  end

  def handle_info(:init, node_option) do
    init_nodeconn(wlan0_ready?(), node_option)
    {:noreply, node_option}
  end

  def handle_info(:wakeup, node_option) do
    nodeconn(node_option)
    {:noreply, node_option}
  end

  def handle_info(:alive, node_option) do
    re_nodeconn(conn_node_alive?(node_option), node_option)
    {:noreply, node_option}
  end

  defp init_nodeconn(true, [node_name, cookie, _]) do
    # node_host = get_ipaddr_wlan0()
    node_host = "#{node_name}.pratipad.local"
    # System.cmd("epmd", ["-daemon"])
    Node.start(:"#{node_name}@#{node_host}")
    Node.set_cookie(:"#{cookie}")

    Logger.info("=== Node.start -> #{node_name}@#{node_host} ===")
    Logger.info("=== Node.set_cookie -> #{cookie} ===")

    case [node_start?(), node_set_cookie?()] do
      [true, true] ->
        Logger.info("=== init_nodeconn -> success! Node.start & Node.set ===")
        set_interval(:wakeup, @interval_wakeup_ms)

      [_, _] ->
        Logger.info(
          "=== init_nodeconn -> false, node_start(#{inspect(node_start?())}), node_set_cookie(#{inspect(node_set_cookie?())}) ==="
        )

        set_interval(:init, @interval_init_ms)
    end
  end

  defp init_nodeconn(false, [_, _, _]) do
    Logger.info("=== init_nodeconn -> false, wlan0_ready(#{inspect(wlan0_ready?())}) ===")
    set_interval(:init, @interval_init_ms)
  end

  defp nodeconn([_, _, conn_node]) do
    conn = Node.connect(:"#{conn_node}")
    Logger.info("=== Node.connect -> try connect to #{conn_node} ===")

    case conn do
      true ->
        Logger.info("=== nodeconn -> #{conn} ===")
        set_interval(:alive, @interval_alive_ms)

      _ ->
        set_interval(:wakeup, @interval_wakeup_ms)
    end
  end

  defp re_nodeconn(:node_alive, _) do
    set_interval(:alive, @interval_alive_ms)
  end

  defp re_nodeconn(:node_re_conn, [_, _, conn_node]) do
    conn = Node.connect(:"#{conn_node}")
    Logger.info("=== re_nodeconn Node.connect -> #{conn_node} ===")

    case conn do
      true ->
        Logger.info("=== re_nodeconn -> #{conn} ===")
        set_interval(:alive, @interval_alive_ms)

      _ ->
        set_interval(:alive, @interval_alive_false_ms)
    end
  end

  defp re_nodeconn(:node_down, [_, _, conn_node]) do
    Logger.debug("=== re_nodeconn -> false... try connect to #{conn_node} ====")
    set_interval(:alive, @interval_alive_false_ms)
  end

  def node_start?() do
    case Node.self() do
      :nonode@nohost -> false
      _ -> true
    end
  end

  def node_set_cookie?() do
    case Node.get_cookie() do
      :nocookie -> false
      _ -> true
    end
  end

  def conn_node_alive?([_, _, conn_node]) do
    case [conn_node_list_find?(conn_node), conn_node_ping?(conn_node)] do
      [true, true] -> :node_alive
      [false, true] -> :node_re_conn
      [_, _] -> :node_down
    end
  end

  def conn_node_list_find?(conn_node) do
    case Node.list() |> Enum.find(fn x -> x == :"#{conn_node}" end) do
      nil -> false
      _ -> true
    end
  end

  def conn_node_ping?(conn_node) do
    case Node.ping(:"#{conn_node}") do
      :pang -> false
      :pong -> true
    end
  end

  def wlan0_ready?() do
    case get_ipaddr_wlan0() do
      nil -> false
      _ -> true
    end
  end

  def get_ipaddr_wlan0() do
    case VintageNet.get_by_prefix(["interface", "wlan0", "addresses"]) do
      [] ->
        nil

      [list_int_wlan0_addr] ->
        list_int_wlan0_addr
        |> (fn {_, list_settings} -> list_settings end).()
        |> hd()
        |> Map.get(:address)
        |> VintageNet.IP.ip_to_string()
    end
  end
end
