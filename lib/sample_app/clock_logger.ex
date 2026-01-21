defmodule SampleApp.ClockLogger do
  @moduledoc """
  Logs human-readable local time once per second.
  """

  @timezone_name "JST"
  @timezone_offset_seconds 9 * 3600

  @tick_interval_ms 1_000

  def start do
    spawn(fn -> tick_forever() end)
    :ok
  end

  defp tick_forever do
    print_local_time()

    receive do
      :stop ->
        :ok

      _ ->
        tick_forever()
    after
      ms_until_next_tick() ->
        tick_forever()
    end
  end

  defp print_local_time do
    {date, clock} = local_date_and_clock()

    IO.puts("time: #{format_date(date)} #{format_clock(clock)} (#{@timezone_name})")
  end

  defp local_date_and_clock do
    wall_clock_seconds = :erlang.system_time(:second) + @timezone_offset_seconds
    :calendar.system_time_to_universal_time(wall_clock_seconds, :second)
  end

  defp ms_until_next_tick do
    now_ms = :erlang.monotonic_time(:millisecond)
    @tick_interval_ms - rem(now_ms, @tick_interval_ms)
  end

  defp format_date({year, month, day}), do: "#{year}-#{pad2(month)}-#{pad2(day)}"

  defp format_clock({hour, minute, second}), do: "#{pad2(hour)}:#{pad2(minute)}:#{pad2(second)}"

  defp pad2(n) when n < 10, do: "0#{n}"
  defp pad2(n), do: Integer.to_string(n)
end
