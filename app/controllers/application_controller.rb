class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  # ---------------------------------------
  # Devise autocomplete helpers
  # ---------------------------------------
  # @return [User]
  def current_user
    super
  end
end
