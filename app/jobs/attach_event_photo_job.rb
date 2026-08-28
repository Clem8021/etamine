class AttachEventPhotoJob < ApplicationJob
  queue_as :default

  def perform(event_id, filename, content_type, base64_data)
    event = Event.find_by(id: event_id)
    return unless event

    decoded = Base64.decode64(base64_data)

    blob = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new(decoded),
      filename: filename,
      content_type: content_type
    )

    event.photos.attach(blob)

    # Pré-génère les variants pendant le job (pas de limite de temps ici),
    # pour que l'affichage soit instantané dès la première visite sur /galerie.
    Event.thumb_variant(blob).processed
    Event.web_variant(blob).processed
  end
end