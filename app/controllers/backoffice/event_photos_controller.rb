module Backoffice
  class EventPhotosController < BaseController
    def destroy
      event = Event.find(params[:event_id])
      photo = event.photos.find(params[:id])
      photo.purge

      redirect_to edit_backoffice_event_path(event), notice: "Photo supprimée."
    end
  end
end