class AddVariantsAndOptionsToProduct < ActiveRecord::Migration[8.0]
 def change
    add_column :products, :product_type, :string unless column_exists?(:products, :product_type)
    add_column :products, :color_options, :string unless column_exists?(:products, :color_options)
    add_column :products, :size_options, :string unless column_exists?(:products, :size_options)
    add_column :products, :addons, :string unless column_exists?(:products, :addons)
    add_column :products, :price_options, :jsonb, default: {} unless column_exists?(:products, :price_options)
    add_column :products, :custom_price_allowed, :boolean, default: false unless column_exists?(:products, :custom_price_allowed)
  end
end
