class DeliveryDetailsController < ApplicationController
  before_action :set_order

  def new
    @delivery_detail = @order.build_delivery_detail
  end

  def create
    @delivery_detail = @order.build_delivery_detail(delivery_detail_params)
    if @delivery_detail.save
      redirect_to @order, notice: "Vos informations de livraison/retrait ont bien été enregistrées."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_order
    @order = Order.find(params[:order_id])
  end

  def delivery_detail_params
    params.require(:delivery_detail).permit(
      :mode, :date, :day, :time_slot,
      :ceremony_info,
      :recipient_name, :recipient_firstname,
      :recipient_address, :recipient_zip, :recipient_city, :recipient_phone,
      :sender_name, :sender_phone,
      :notes
    )
  end
end
