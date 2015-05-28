class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  protect_from_forgery with: :null_session

  before_action :configure_permitted_parameters, if: :devise_controller?

  def after_sign_in_path_for(resource)
    if resource.is_a?(Venue)
      venue_root_path
    elsif resource.is_a?(WebUser)
      venues_path
    else
      super
    end
  end

  def after_sign_out_path_for(resource)
    # TODO add redirect when users logout
    # puts "AAAAAA"
    # puts resource.inspect
    # if resource.is_a?(WebUser) or resource == "web_user"
    #   puts "AAA"
    #   new_web_user_session_path
    # else
    #   super
    # end
    new_web_user_session_path
  end

  # Every user must be authenticated when accessing the API from the iOS client
  def authenticate_api
    unless User.find_by_key(params[:key])
      render json: error("You must authenticate with an API Key")
    end
  end

  def current_user
    logger.info "KEY: " + params[:key]
    User.find_by_key(params[:key])
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << [:name, :address_line_one, :city, :state, :country, :zipcode, :business_phone, :age_requirement, :dress_code, :venue_name, :web_user_name, :job_title]
    devise_parameter_sanitizer.for(:account_update) << [:name, :address_line_one, :city, :state, :country, :zipcode, :phone, :age_requirement, :dress_code]
  end

  # Easy way to send back success/failed API calls

  def success(data = nil, data_symbol_name="data")
    response = {
      success: true,
      data_symbol_name.to_sym => data
    }
    # if data.present?
    #   response.merge!({ data: data})
    # end
    # response.as_json
  end

  def error(message)
    {
      success: false,
      message: message
    }
  end

  def mobile_device?
    if session[:mobile_param]
    session[:mobile_param] == "1"
    else
    request.user_agent =~ /Mobile|webOS/
    end
  end
  helper_method :mobile_device?

end
