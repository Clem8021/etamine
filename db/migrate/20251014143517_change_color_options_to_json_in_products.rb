class ChangeColorOptionsToJsonInProducts < ActiveRecord::Migration[8.0]
  def change
    change_column :products, :color_options, :jsonb, using: 'color_options::jsonb'
  end
end
