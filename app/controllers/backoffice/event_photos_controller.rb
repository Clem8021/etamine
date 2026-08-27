module Backoffice
  class EventPhotosController < BaseController
    def destroy
      @event = Event.find(params[:event_id])
      @photo = @event.photos.find(params[:id])
      @photo.purge

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to edit_backoffice_event_path(@event), notice: "Photo supprimée." }
      end
    end
  end
end