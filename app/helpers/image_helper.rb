module ImageHelper
  # Désactive Cloudinary et utilise juste les assets locaux
  def smart_image_tag(source, **options)
    image_tag(source, **options)
  end
end
