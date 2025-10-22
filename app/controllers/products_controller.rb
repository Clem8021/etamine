class ProductsController < ApplicationController
  # === PAGE BOUTIQUE ===
  def index
    if params[:category].present? && Product::CATEGORIES.include?(params[:category])
      selected_category = params[:category]

      if selected_category == "roses"
        # ✅ Cas spécial Roses → uniquement les variétés valides
        roses = Product.where(category: "roses", variety: Product::ROSE_VARIETIES)

        # On regroupe par variété et on prend un produit par variété
        grouped_roses = roses.group_by(&:variety)
        unique_roses  = grouped_roses.map { |_variety, products| products.first }

        @products_by_category = { "roses" => unique_roses }
      else
        # ✅ Autres catégories
        @products_by_category = {
          selected_category => Product.where(category: selected_category)
        }
      end
    else
      # ✅ Pas de paramètre → toutes les catégories valides
      @products_by_category = Product.where(category: Product::CATEGORIES).group_by(&:category)
    end
  end

  # === PAGE PRODUIT ===
  def show
    @product = Product.find_by(id: params[:id])
    if @product.nil?
      redirect_to products_path, alert: "Ce produit n’existe plus ou a été supprimé."
      return
    end

    @order = current_order
    @order_item = @order.order_items.new
  end

  # === PAGE PREVIEW PRIVÉE POUR CLIENTE ===
  def preview
    # 🔓 accès libre à la preview sans verrou global
    if params[:key] != ENV["PREVIEW_KEY"]
      redirect_to root_path, alert: "Accès non autorisé."
      return
    end

    @products_by_category = Product.where(category: Product::CATEGORIES).group_by(&:category)
    render :index
  end
end
