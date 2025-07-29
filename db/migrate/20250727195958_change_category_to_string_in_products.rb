class ChangeCategoryToStringInProducts < ActiveRecord::Migration[8.0]
  def change
    change_column :products, :category, :string
  end
end
