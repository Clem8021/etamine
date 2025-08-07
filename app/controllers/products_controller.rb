class ProductsController < ApplicationController
  def index
    if params[:category].present? && Product::CATEGORIES.include?(params[:category])
      selected_category = params[:category]
      @products_by_category = {
        selected_category => Product.where(category: selected_category)
      }
    else
      # Pas de catégorie sélectionnée, on affiche tous les produits groupés par catégorie
      @products_by_category = Product.all.group_by(&:category)
    end
  end

  def show
    @product = Product.find(params[:id])
    @order = current_order
  end
end
