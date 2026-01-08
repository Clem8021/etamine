class AddGalleryImagesToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :gallery_images, :json
  end
end
