module Backoffice
  class EventsController < BaseController
    before_action :set_event, only: [:edit, :update, :destroy]

    def index
      @events = Event.ordered
    end

    def new
      @event = Event.new
    end

    def create
      @event = Event.new(event_params)

      if @event.save
        attach_photos
        redirect_to backoffice_events_path, notice: "Événement créé."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @event.update(event_params)
        attach_photos
        redirect_to backoffice_events_path, notice: "Événement mis à jour."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @event.destroy
      redirect_to backoffice_events_path, notice: "Événement supprimé."
    end

    private

    def set_event
      @event = Event.find(params[:id])
    end

    def event_params
      params.require(:event).permit(:title, :event_date, :active)
    end

    # Upload multiple : le champ photos[] du formulaire est géré à part
    # (il n'est pas dans event_params pour ne pas écraser les photos existantes à chaque update)
    def attach_photos
      new_photos = params.dig(:event, :photos)
      return if new_photos.blank?

      @event.photos.attach(new_photos.reject(&:blank?))
    end
  end
end