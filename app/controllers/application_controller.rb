class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  def after_sign_in_path_for(resource)
    if resource.is_a?(Venue)
      venue_root_path
    end
  end

  def authenticate_api

  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << [:name, :address_line_one, :city, :state, :country, :zipcode, :phone, :age_requirement, :dress_code]
    devise_parameter_sanitizer.for(:account_update) << [:name, :address_line_one, :city, :state, :country, :zipcode, :phone, :age_requirement, :dress_code]
  end

  def success(data)
    {
      success: true,
      data: data
    }
  end

  def error(message)
    {
      success: false,
      message: message
    }
  end
end
