defmodule ElephantCarpaccioWeb.CalculationLive do
  use ElephantCarpaccioWeb, :live_view

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <.header>Emissions Simulator</.header>

    <.form for={@form} phx-submit="calculate-emissions">
      <.input field={@form[:num_containers]} label="How many containers ?" value="1" />
      <.input field={@form[:origin_port]} label="Origin port" value="Marseilles" />
      <.input field={@form[:destination_port]} label="Destination port" value="Mumbai" />
      <.input field={@form[:fuel_type]} label="Fuel type" value="fossil" />

      <p :if={@emissions} class="my-2">
        🌱 Your shipment will emit <%= @emissions %>g of carbon dioxide.
      </p>

      <div class="my-4">
        <.button type="submit">
          Calculate
        </.button>
      </div>
    </.form>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(form: to_form(%{}), emissions: nil)}
  end

  @impl Phoenix.LiveView
  def handle_event("calculate-emissions", _params, socket) do
    {:noreply, socket |> assign(:emissions, 1200)}
  end
end
