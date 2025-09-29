class ProductsController < ApplicationController
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
        # ✅ Autre catégorie
        @products_by_category = {
          selected_category => Product.where(category: selected_category)
        }
      end
    else
      # ✅ Pas de paramètre → uniquement les catégories valides
      @products_by_category = Product.where(category: Product::CATEGORIES).group_by(&:category)
    end
  end

  def show
    @product = Product.find(params[:id])
    @order   = current_order
    @order_item = @order.order_items.new
  end
end
