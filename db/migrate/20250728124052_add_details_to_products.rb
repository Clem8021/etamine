class AddDetailsToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :customizable_price, :boolean
    add_column :products, :min_price_cents, :integer
    add_column :products, :color_options, :string
    add_column :products, :size_options, :string
    add_column :products, :addons, :string
  end
end
