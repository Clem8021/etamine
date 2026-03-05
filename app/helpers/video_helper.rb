module VideoHelper
  def cloud_video_tag(public_id, **options)
    url = Cloudinary::Utils.cloudinary_url(
      public_id,
      resource_type: :video,
      **options.delete(:cloudinary_options) || {}
    )
    tag.video(**options) do
      tag.source(src: url, type: "video/mp4")
    end
  end
end
