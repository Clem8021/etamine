class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description
      t.integer :price_cents
      t.string :category
      t.string :image_url
      t.integer :stock_quantity

      t.timestamps
    end
  end
end
