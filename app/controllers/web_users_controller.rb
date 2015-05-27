class WebUsersController < ApplicationController

  before_action :authenticate_web_user!, only: [:edit, :update]


  def edit
    @id = current_web_user.id
    @web_user = WebUser.find_by_id(@id)
    
  end

  def update
    @web_user = WebUser.find_by_id(params[:id])


    
  end

end