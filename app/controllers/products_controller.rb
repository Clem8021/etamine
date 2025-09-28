class ProductsController < ApplicationController
  def index
    if params[:category].present? && Product::CATEGORIES.include?(params[:category])
      selected_category = params[:category]

      if selected_category == "roses"
        # ✅ Cas spécial Roses → seulement 3 variétés (un produit par variété)
        roses = Product.where(category: "roses")
                       .where("name ILIKE ANY ( array[?] )", ["%Rouge Explorer%", "%Rose Espérance%", "%Blanche%"])

        grouped_roses = roses.group_by { |p| p.name.split(" ").last }
        unique_roses  = grouped_roses.map { |_variety, products| products.first }

        @products_by_category = { "roses" => unique_roses }
      else
        # ✅ Autre catégorie
        @products_by_category = {
          selected_category => Product.where(category: selected_category)
        }
      end
    else
      # ✅ Pas de paramètre → toutes les catégories
      @products_by_category = Product.all.group_by(&:category)
    end
  end

  def show
    @product = Product.find(params[:id])
    @order   = current_order
    @order_item = @order.order_items.new
  end
end
