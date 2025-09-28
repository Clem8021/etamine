class DeliveryDetailsController < ApplicationController
  before_action :set_order
  before_action :set_delivery_detail, only: [:edit, :update]

  def new
    @delivery_detail = @order.build_delivery_detail
  end

  def edit
    @order = current_user.orders.find(params[:order_id])
    @delivery_detail = @order.delivery_detail
  end

  def create
    @delivery_detail = @order.build_delivery_detail(delivery_detail_params)
    if @delivery_detail.save
      redirect_to checkout_order_path(@order), notice: "✅ Informations enregistrées."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @delivery_detail.update(delivery_detail_params)
      redirect_to checkout_order_path(@order), notice: "✅ Informations enregistrées."
    else
      Rails.logger.debug @delivery_detail.errors.full_messages
      flash.now[:alert] = @delivery_detail.errors.full_messages.join(", ")
      render :new, status: :unprocessable_entity
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
      :mode, :date, :time_slot, :recipient_name, :recipient_firstname,
      :recipient_address, :recipient_zip, :recipient_city, :recipient_phone,
      :notes,
      :ceremony_date, :ceremony_time, :ceremony_location # ✅ nouveaux champs
    )
  end
end
