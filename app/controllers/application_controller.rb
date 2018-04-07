class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end

  rescue_from ActiveRecord::RecordNotUnique, :with => :record_not_uniq
  

  helper_method :resource_name, :resource, :devise_mapping, :resource_class

  def resource_name
    :user
  end
  
  def resource
    @resource ||= User.new
  end

  def resource_class
    User
  end
  
  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :provider, :uid])
    end

    def record_not_uniq
      redirect_back(fallback_location: root_path) 
    end

end
