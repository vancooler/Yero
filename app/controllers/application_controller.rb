class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  protect_from_forgery with: :null_session

  before_action :configure_permitted_parameters, if: :devise_controller?
  after_action :allow_optimizely_editor
  before_filter :add_www_subdomain

  # :nocov:
  def after_sign_in_path_for(resource)
    if resource.is_a?(Venue)
      venue_root_path
    elsif resource.is_a?(WebUser)
      venues_path
    else
      super
    end
  end
  # :nocov:

  # :nocov:
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
  # :nocov:

  # Every user must be authenticated when accessing the API from the iOS client
  def authenticate_api_v2
    result = User.authenticate_v2(params[:token])
    if result['success'] == true

    else
      render json: error(result['error_data'], 'error')
    end

  end

  # Every user must be authenticated when accessing the API from the iOS client
  def authenticate_api
    if Rails.env == 'development' or Rails.env == 'test'
      secret = 'secret'
    else
      secret = ENV['SECRET_KEY_BASE']
    end
    if params[:token].blank?
      render json: error("You must authenticate with a valid token")
    else
      token = params[:token].split(' ').last
      begin
        token_info = JWT.decode(token, secret)
        if token_info.nil? or token_info.empty? or token_info.first.nil?
          render json: error("You must authenticate with a valid token")
        else
          user_info = token_info.first
          user_id = user_info['id']
          if user_id.nil?
            render json: error("You must authenticate with a valid token")
          else
            user = User.find_user_by_unique(user_id.to_i)
            if user.nil?
              render json: error("You must authenticate with a valid token")
            else
              user.last_active = Time.now
              user.version = '1.0'
              user.save!
            end
          end
        end

      rescue JWT::ExpiredSignature
        render json: error("Token Expired")
      rescue JWT::DecodeError
        render json: error("You must authenticate with a valid token")
      end
    end


    ########################
    # KEY auth
    ######################## 
    # user = User.find_by_key(params[:key])
    # if !user.nil?
    #   # check expiration and extend if still valid
    #   if user.key_expiration.nil? or user.key_expiration > Time.now
    #     user.key_expiration = Time.now + 3.hours
    #     user.save!
    #   else
    #     render json: error("API Key Expired")
    #   end
    # else
    #   render json: error("You must authenticate with an API Key")
    # end
  end

  def current_user
    if Rails.env == 'development' or Rails.env == 'test'
      secret = 'secret'
    else
      secret = ENV['SECRET_KEY_BASE']
    end
    if params[:token].blank?
      nil
    end
    token = params[:token].split(' ').last
    begin
      token_info = JWT.decode(token, secret)
    rescue JWT::ExpiredSignature
      token_info = nil
    rescue JWT::DecodeError
      token_info = nil
    end

    if token_info.nil? or token_info.empty? or token_info.first.nil?
      nil
    else
      user_info = token_info.first
      user_id = user_info['id']
      if user_id.nil?
        nil
      else
        User.find_user_by_unique(user_id.to_i)
      end
    end


    # logger.info "KEY: " + params[:key]
    # User.find_by_key(params[:key])
  end

  protected

  # :nocov:
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << [:name, :address_line_one, :city, :state, :country, :zipcode, :business_phone, :age_requirement, :dress_code, :venue_name, :web_user_name, :job_title]
    devise_parameter_sanitizer.for(:account_update) << [:name, :address_line_one, :city, :state, :country, :zipcode, :phone, :age_requirement, :dress_code]
  end
  # :nocov:

  # Easy way to send back success/failed API calls

  def success(data = nil, data_symbol_name="data", pagination_dictionary = nil)
    if pagination_dictionary.nil?
      response = {
        success: true,
        data_symbol_name.to_sym => data
      }
    else
      response = {
        success: true,
        pagination: pagination_dictionary,
        data_symbol_name.to_sym => data
      }
    end
    # if data.present?
    #   response.merge!({ data: data})
    # end
    # response.as_json
  end

  def error(message, data_symbol_name="message")
    {
      success: false,
      data_symbol_name.to_sym => message
    }
  end

  # :nocov:
  def mobile_device?
    if session[:mobile_param]
    session[:mobile_param] == "1"
    else
    request.user_agent =~ /Mobile|webOS/
    end
  end
  helper_method :mobile_device?
  # :nocov:
  
  private

  def allow_optimizely_editor
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Request-Method'] = 'GET'
  end

  # :nocov:
  def add_www_subdomain
    # puts "request"
    # puts request.path
    if Rails.env != "test"
      unless /^www/.match(request.host) or request.host_with_port == 'localhost:3000' or request.host == 'purpleoctopus-staging.herokuapp.com' or request.host == 'purpleoctopus-dev.herokuapp.com' or request.host == 'dev.yero.co' or request.host == 'api.yero.co' or request.host == 'devapi.yero.co'
        redirect_to("#{request.protocol}www.#{request.host_with_port}#{request.path}",
                    :status => 301)
      end
    end
  end
  # :nocov:

end
