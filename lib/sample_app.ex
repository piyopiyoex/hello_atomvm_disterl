defmodule SampleApp do
  @moduledoc """
  Entry point for the AtomVM application.
  """

  def start do
    SampleApp.Provision.maybe_provision()
    SampleApp.WiFi.start()
    SampleApp.ClockLogger.start()

    Process.sleep(:infinity)
  end
end
