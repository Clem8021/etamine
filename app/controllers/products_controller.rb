class ProductsController < ApplicationController
  # === PAGE BOUTIQUE ===
  def index
    if params[:category].present? && Product::CATEGORIES.include?(params[:category])
      selected_category = params[:category]

      if selected_category == "roses"
        roses = Product.where(category: "roses", variety: Product::ROSE_VARIETIES)
        grouped_roses = roses.group_by(&:variety)
        unique_roses  = grouped_roses.map { |_variety, products| products.first }
        @products_by_category = { "roses" => unique_roses }
      else
        @products_by_category = { selected_category => Product.where(category: selected_category) }
      end
    else
      @products_by_category = Product.where(category: Product::CATEGORIES).group_by(&:category)
    end
  end

  # === PAGE PRODUIT ===
  def show
    @product = Product.find_by(id: params[:id])
    unless @product
      redirect_to products_path, alert: "Ce produit n’existe plus ou a été supprimé."
      return
    end

    @order = current_order
    @order_item = @order.order_items.new
  end

  # === PAGE PREVIEW PRIVÉE POUR CLIENTE ===
  def preview
    # Active la session preview si la bonne clé est fournie
    if params[:key].to_s.strip == ENV["PREVIEW_KEY"].to_s.strip
      session[:preview_mode] = true
    end

    # Autorise si la session preview est active (même sans repasser la clé)
    unless session[:preview_mode] == true
      redirect_to root_path, alert: "Accès non autorisé."
      return
    end

    @products_by_category = Product.where(category: Product::CATEGORIES).group_by(&:category)
    render :index
  end
end
