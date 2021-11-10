class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  # ---------------------------------------
  # Devise autocomplete helpers
  # ---------------------------------------
  # @return [User]
  def current_user
    super
  end

  protected

  def configure_permitted_parameters
    keys = %i[
      first_name
      last_name
      sex
      birthday
      avatar
    ].freeze
    devise_parameter_sanitizer.permit(:sign_up, keys: keys)
    devise_parameter_sanitizer.permit(:account_update, keys: keys)
  end
end
