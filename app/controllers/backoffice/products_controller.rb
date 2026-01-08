module Backoffice
  class ProductsController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin!
    before_action :set_product, only: [:edit, :update, :toggle_active]

    def index
      products = Product.order(updated_at: :desc).to_a
      @products_by_category = products.group_by(&:category)
    end

    def new
      @product = Product.new
    end

    def create
      @product = Product.new

      if assign_product_attributes(@product) && @product.save
        redirect_to backoffice_products_path, notice: "Produit créé."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if assign_product_attributes(@product) && @product.save
        redirect_to backoffice_products_path, notice: "Produit mis à jour."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def toggle_active
      @product.update!(active: !@product.active)
      redirect_to backoffice_products_path, notice: "Produit mis à jour."
    end

    private

    def set_product
      @product = Product.find(params[:id])
    end

    # Permitted params “bruts”
    def raw_product_params
      params.require(:product).permit(
        :name, :category, :variety,
        :price_cents, :size_options, :color_options, :addons,
        :image_url, :active,
        :price_options
      )
    end

    # Assigne + parse le JSON proprement. Retourne true/false.
    def assign_product_attributes(product)
      permitted = raw_product_params.to_h

      # price_options peut arriver en String (textarea) -> on parse
      if permitted["price_options"].is_a?(String)
        json = permitted["price_options"].strip
        if json.blank?
          permitted["price_options"] = nil
        else
          permitted["price_options"] = JSON.parse(json)
        end
      end

      product.assign_attributes(permitted)
      true
    rescue JSON::ParserError
      product.assign_attributes(raw_product_params.except(:price_options))
      product.errors.add(:price_options, "doit être un JSON valide (ex: {\"10\":2500,\"20\":4200})")
      false
    end
  end
end
