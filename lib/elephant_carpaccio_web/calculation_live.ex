defmodule ElephantCarpaccioWeb.CalculationLive do
  use ElephantCarpaccioWeb, :live_view

  @ports ~w[
    Marseilles
    Mumbai
    Copenhagen
    Rotterdam
    Manhattan
  ]

  @fuel_types ~w[fossil methanol ECO1 ECO2 ECO3]

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <.header>Emissions Simulator</.header>

    <.form for={@form} phx-submit="calculate-emissions">
      <.input type="number" field={@form[:num_containers]} label="How many containers ?" value="1" />
      <.input
        type="select"
        options={@ports}
        field={@form[:origin_port]}
        label="Origin port"
        value="Marseilles"
      />
      <.input
        type="select"
        options={@ports}
        field={@form[:destination_port]}
        label="Destination port"
        value="Mumbai"
      />
      <.input
        type="select"
        options={@fuel_types}
        field={@form[:fuel_type]}
        label="Fuel type"
        value="fossil"
      />

      <div :if={@result} class="my-2">
        <p>
          🌱 Your shipment will emit <%= @result.emissions %>g of carbon dioxide.
        </p>
        <p>
          💸 Using <%= @result.fuel_type %> will cost you an additional $<%= @result.surcharge %>
        </p>
      </div>

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
    {:ok,
     socket
     |> assign(
       form: to_form(%{}),
       ports: @ports,
       fuel_types: @fuel_types,
       result: nil,
       fuel_type: nil
     )}
  end

  @impl Phoenix.LiveView
  def handle_event(
        "calculate-emissions",
        %{
          "num_containers" => num_containers,
          "destination_port" => to,
          "origin_port" => from,
          "fuel_type" => fuel_type
        } = _params,
        socket
      ) do
    how_many = String.to_integer(num_containers)

    {:noreply,
     socket
     |> assign(
       result: %{
         fuel_type: fuel_type,
         emissions: fuel_consumption(from, to) * how_many,
         surcharge: surcharge_for(fuel_type) * how_many
       }
     )}
  end

  @surcharges %{
    "fossil" => 0,
    "methanol" => 31,
    "ECO1" => 10,
    "ECO2" => 47,
    "ECO3" => 101
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
