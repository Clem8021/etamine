class AddFeaturedPhotoIdsToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :featured_photo_ids, :text, default: "[]"
  end
end