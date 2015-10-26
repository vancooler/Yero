module V20150930  
  class SpotifyController < ApplicationController
    prepend_before_filter :get_api_token
    before_action :authenticate_api_v2

    def auth
      
    end

    def refresh

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