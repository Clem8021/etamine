class AddIndexToOrdersArchivedAt < ActiveRecord::Migration[8.0]
  add_index :orders, :archived_at
  def change
  end
end
