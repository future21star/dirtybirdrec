class Users::RegistrationsController < Devise::RegistrationsController
  before_action :set_notifications, only: [:new, :edit]

  protected

  def after_sign_up_path_for(resource)
    choose_profile_path
  end
end