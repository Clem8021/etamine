class ProductsController < ApplicationController
  def index
    if params[:category].present? && Product::CATEGORIES.include?(params[:category])
      @products_by_category = {
        params[:category] => Product.where(category: params[:category])
      }
    else
      @products_by_category = Product.all.group_by(&:category)
    end
  end

  def show
    @product = Product.find(params[:id])
  end
end
