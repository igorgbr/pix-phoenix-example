defmodule PixDemoWeb.PixLive do
  use PixDemoWeb, :live_view

  @chave "123e4567-e12b-12d1-a456-426655440000"

  def mount(_params, _session, socket) do
    form = to_form(%{"valor" => "", "descricao" => ""})
    {:ok, assign(socket, form: form, payload: nil, qr: nil, erro: nil)}
  end

  def handle_event("gerar", %{"valor" => valor, "descricao" => descricao}, socket) do
    params = %{
      key: @chave,
      merchant_name: "Coisa de Dev",
      merchant_city: "São Paulo",
      amount: String.replace(valor, ",", ".")
    }

    params = if descricao == "", do: params, else: Map.put(params, :description, descricao)

    case PixBrcode.encode(params) do
      {:ok, payload} ->
        qr = payload |> EQRCode.encode() |> EQRCode.svg(width: 280)
        {:noreply, assign(socket, payload: payload, qr: qr, erro: nil)}

      {:error, motivo} ->
        {:noreply, assign(socket, payload: nil, qr: nil, erro: motivo)}
    end
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.form for={@form} phx-submit="gerar">
        <.input field={@form[:valor]} label="Valor (ex: 10,50)" />
        <.input field={@form[:descricao]} label="Descrição (opcional)" />
        <.button>Gerar Pix</.button>
      </.form>

      <p :if={@erro} class="mt-4 text-error">Erro: {inspect(@erro)}</p>

      <div :if={@qr} class="mt-6 space-y-4">
        {Phoenix.HTML.raw(@qr)}
        <textarea readonly class="textarea w-full font-mono text-xs">{@payload}</textarea>
      </div>
    </Layouts.app>
    """
  end
end
