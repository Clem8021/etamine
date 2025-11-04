class DeliveryDetailsController < ApplicationController
  before_action :set_order
  before_action :set_delivery_detail, only: [:edit, :update]

  def new
    @delivery_detail = @order.build_delivery_detail unless @order.delivery_detail
    @delivery_detail ||= @order.delivery_detail
  end

  def edit; end

  def create
    @delivery_detail = @order.build_delivery_detail
    assign_and_sanitize_params!(@delivery_detail)

    if @delivery_detail.save
      session[:order_id] = @order.id
      redirect_to checkout_order_path(@order, ready_for_payment: true),
                  notice: "✅ Informations enregistrées. Vérifiez votre commande avant paiement."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    assign_and_sanitize_params!(@delivery_detail)

    if @delivery_detail.save
      session[:order_id] = @order.id
      redirect_to checkout_order_path(@order, ready_for_payment: true),
                  notice: "✅ Informations mises à jour. Vérifiez votre commande avant paiement."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_order
    @order = Order.find(params[:order_id])
  end

  def set_delivery_detail
    @delivery_detail = @order.delivery_detail || @order.build_delivery_detail
  end

  def delivery_detail_params
    params.require(:delivery_detail).permit(
      :mode, :date, :time_slot,
      :recipient_name, :recipient_firstname, :recipient_address, :recipient_zip,
      :recipient_city, :recipient_phone,
      :notes,
      :ceremony_date, :ceremony_time, :ceremony_location
    )
  end

  # 👇 Sanitise selon le mode choisi
  def assign_and_sanitize_params!(detail)
    attrs = delivery_detail_params.to_h

    case attrs["mode"]
    when "pickup"
      # on purge tout ce qui est lié à la livraison + deuil
      %w[
        recipient_name recipient_firstname recipient_address recipient_zip
        recipient_city recipient_phone ceremony_date ceremony_time ceremony_location
      ].each { |k| attrs[k] = nil }
    when "delivery"
      # ok, on laisse tel quel (les validations feront le tri)
    else
      # pas de mode → on s'assure de ne pas traîner de valeurs
      %w[
        recipient_name recipient_firstname recipient_address recipient_zip
        recipient_city recipient_phone ceremony_date ceremony_time ceremony_location
      ].each { |k| attrs[k] = nil }
    end

    detail.assign_attributes(attrs)
  end
end
