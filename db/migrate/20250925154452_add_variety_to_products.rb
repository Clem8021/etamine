class AddVarietyToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :variety, :string
  end
end
