module V20150930  
  class PusherController < ApplicationController
    prepend_before_filter :get_api_token, only: [:auth]
      

    def auth
      if current_user
        response = Pusher[params[:channel_name]].authenticate(params[:socket_id])
        render :json => response
      else
        render :text => "Forbidden", :status => '403'
      end
    end

    private
    def get_api_token
      if (Rails.env != 'test' && api_token = params[:token].blank? && request.headers["X-API-TOKEN"])
        # :nocov:
        params[:token] = api_token 
        # :nocov:
      end
    end
  end
end