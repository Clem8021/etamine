class AttachEventPhotoJob < ApplicationJob
  queue_as :default

  def perform(event_id, filename, content_type, base64_data)
    event = Event.find_by(id: event_id)
    return unless event # l'événement a pu être supprimé entre-temps

    decoded = Base64.decode64(base64_data)

    event.photos.attach(
      io: StringIO.new(decoded),
      filename: filename,
      content_type: content_type
    )
  end
end