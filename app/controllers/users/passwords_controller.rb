class Users::PasswordsController < Devise::PasswordsController
  def create
    self.resource = resource_class.find_by(email: resource_params[:email])

    unless resource
      flash.now[:alert] = "Aucun compte n’est associé à cet email."
      respond_with({}, location: new_user_password_path)
      return
    end

    self.resource.send_reset_password_instructions
    flash[:notice] = "📧 Un lien de réinitialisation vous a été envoyé par email."
    redirect_to new_user_session_path
  end
end
