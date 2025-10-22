class ProductsController < ApplicationController
  # ✅ On saute le filtre uniquement s’il est défini (protège du crash en prod)
  skip_before_action :redirect_to_home_if_locked, only: [:preview], if: -> { ApplicationController._process_action_callbacks.map(&:filter).include?(:redirect_to_home_if_locked) }

  def index
    if params[:category].present? && Product::CATEGORIES.include?(params[:category])
      selected_category = params[:category]

      if selected_category == "roses"
        # ✅ Cas spécial Roses → uniquement les variétés valides
        roses = Product.where(category: "roses", variety: Product::ROSE_VARIETIES)
        grouped_roses = roses.group_by(&:variety)
        unique_roses  = grouped_roses.map { |_variety, products| products.first }
        @products_by_category = { "roses" => unique_roses }
      else
        @products_by_category = {
          selected_category => Product.where(category: selected_category)
        }
      end
    else
      # ✅ Pas de paramètre → toutes les catégories valides
      @products_by_category = Product.where(category: Product::CATEGORIES).group_by(&:category)
    end
  end

  def show
    @product = Product.find_by(id: params[:id])
    if @product.nil?
      redirect_to products_path, alert: "Ce produit n’existe plus ou a été supprimé."
      return
    end

    @order = current_order
    @order_item = @order.order_items.new
  end

  def preview
    # 🔒 Vérifie la clé d’accès privée
    if params[:key].to_s.strip == ENV["PREVIEW_KEY"].to_s.strip
      session[:preview_mode] = true
      @products_by_category = Product.where(category: Product::CATEGORIES).group_by(&:category)
      render :index
    else
      redirect_to root_path, alert: "Accès non autorisé"
    end
  end
end
