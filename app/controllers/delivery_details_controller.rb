class DeliveryDetailsController < ApplicationController
  before_action :set_order
  before_action :set_delivery_detail, only: [:edit, :update]

  def new
    @delivery_detail = @order.build_delivery_detail
  end

  def edit
    @delivery_detail = @order.delivery_detail
  end

  def create
    @delivery_detail = @order.build_delivery_detail(delivery_detail_params)
    if @delivery_detail.save
      # 🔹 On garde cette commande comme commande active
      session[:order_id] = @order.id

      redirect_to checkout_order_path(@order, ready_for_payment: true),
                  notice: "✅ Informations enregistrées. Vérifiez votre commande avant paiement."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @delivery_detail.update(delivery_detail_params)
      session[:order_id] = @order.id # ✅ garde la bonne commande
      redirect_to checkout_order_path(@order, ready_for_payment: true),
                  notice: "✅ Informations mises à jour. Vérifiez votre commande avant paiement."
    else
      flash.now[:alert] = @delivery_detail.errors.full_messages.join(", ")
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
      :recipient_name, :recipient_firstname,
      :recipient_address, :recipient_zip, :recipient_city, :recipient_phone,
      :notes,
      :ceremony_date, :ceremony_time, :ceremony_location
    )
  end
end
