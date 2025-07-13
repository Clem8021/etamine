class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.string :full_name
      t.text :address
      t.string :email
      t.string :status
      t.integer :total_cents

      t.timestamps
    end
  end
end
