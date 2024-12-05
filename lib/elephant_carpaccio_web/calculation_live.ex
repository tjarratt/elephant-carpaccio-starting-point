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
      <p :if={@fuel_type}>
        💸 Using <%= @fuel_type %> will cost you an additional $<%= @surcharge %>
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
    {:ok, socket |> assign(form: to_form(%{}), emissions: nil, surcharge: nil, fuel_type: nil)}
  end

  @impl Phoenix.LiveView
  def handle_event(
        "calculate-emissions",
        %{"destination_port" => to, "origin_port" => from, "fuel_type" => fuel_type} = _params,
        socket
      ) do
    {:noreply,
     socket
     |> assign(
       emissions: fuel_consumption(from, to),
       surcharge: surcharge_for(fuel_type),
       fuel_type: "fossil"
     )}
  end

  @surcharges %{
    "fossil" => 0,
    "methanol" => 31
  }

  defp surcharge_for(fuel_type) do
    Map.fetch!(@surcharges, fuel_type)
  end

  @fuel_consumption %{
    "Marseilles_Mumbai" => 1200,
    "Mumbai_Manhattan" => 2701,
    "Manhattan_Copenhagen" => 1937,
    "Rotterdam_Copenhagen" => 578,
    "Marseilles_Copenhagen" => 429,
    "Copenhagen_Marseilles" => 777,
    "Mumbai_Copenhagen" => 2302,
    "Rotterdam_Mumbai" => 1568,
    "Copenhagen_Manhattan" => 1837,
    "Marseilles_Rotterdam" => 576,
    "Copenhagen_Mumbaai" => 2538,
    "Mumbai_Marseilles" => 1148,
    "Rotterdam_Manhattan" => 755,
    "Copenhagen_Mumbai" => 3159
  }

  defp fuel_consumption(from, to) do
    Map.get(@fuel_consumption, "#{from}_#{to}")
  end
end
