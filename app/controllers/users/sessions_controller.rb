class Users::SessionsController < Devise::SessionsController
  # Avant connexion
  # before_action :configure_sign_in_params, only: [:create]

  # GET /users/sign_in
  # def new
  #   super
  # end

  # POST /users/sign_in
  # def create
  #   super
  # end

  # DELETE /users/sign_out
  # def destroy
  #   super
  # end

  protected

  # Si tu veux autoriser des params en plus lors du sign in
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
