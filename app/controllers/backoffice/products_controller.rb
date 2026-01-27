module Backoffice
  class ProductsController < BaseController
    before_action :set_product, only: [:edit, :update, :toggle_active, :destroy]

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

    def destroy
      @product.destroy
      redirect_to backoffice_products_path, notice: "Produit supprimé."
    end

    private

    def set_product
      @product = Product.find(params[:id])
    end

    def raw_product_params
      params.require(:product).permit(
        :name, :category, :variety,
        :price_cents, :customizable_price, :size_options, :color_options, :addons,
        :image_url, :active, :photo,
        message_card_ids: []
      )
    end

    # Format accepté:
    # 25€: 25
    # Grand: 90
    # (prix en euros, virgule acceptée)
    def parse_price_options_text(text)
      return nil if text.blank?

      options = {}

      text.lines.each_with_index do |line, idx|
        line = line.strip
        next if line.blank?

        unless line.include?(":")
          raise ArgumentError, "Ligne #{idx + 1}: il manque ':' (ex: 25€: 25)"
        end

        label, euros = line.split(":", 2).map { |s| s&.strip }
        if label.blank? || euros.blank?
          raise ArgumentError, "Ligne #{idx + 1}: format invalide (ex: 25€: 25)"
        end

        euros = euros.tr(",", ".")
        unless euros.match?(/\A\d+(\.\d{1,2})?\z/)
          raise ArgumentError, "Ligne #{idx + 1}: prix invalide (ex: 25 ou 25,5)"
        end

        cents = (euros.to_f * 100).round
        options[label] = cents
      end

      options.presence
    end

    # Assigne les champs et convertit price_options_text => price_options (Hash)
    def assign_product_attributes(product)
      permitted = raw_product_params.to_h

      price_text = permitted.delete("price_options_text")

      if price_text.present?
        permitted["price_options"] = parse_price_options_text(price_text)
        permitted["customizable_price"] = true
      end

      product.assign_attributes(permitted)
      true
    rescue ArgumentError => e
      product.assign_attributes(raw_product_params.except(:price_options_text))
      product.errors.add(:base, e.message)
      false
    end
  end
end
