class GreetingMessagesController < ApplicationController

  before_action :authenticate_web_user!, only: [:edit_message, :update]

  # edit page
  def edit_message
    @venue = Venue.find_by_id(params['id'])
    @day = Weekday.find_by_weekday_title(params['day']) # param day should be capitalized
  	WebUser.mixpanel_event(current_web_user.id, 'View greeting message edit', {
		    'Day' => @day.weekday_title,
		    'Venue' => (@venue.blank? ? '' : @venue.name)
	  })
  	if mobile_device?
      @device = "mobile"
    else
      @device = "regular"
    end

    @greeting_message = GreetingMessage.find_by_venue_id_and_weekday_id(@venue.id, @day.id)
    if @greeting_message.nil?
      @greeting_message = GreetingMessage.new
      @greeting_message.venue_id = @venue.id
      @greeting_message.weekday_id = @day.id
      @greeting_message.save
    end
  end


  # save action
  def update
    @venue = Venue.find_by_id(params['id'])
    @day = Weekday.find_by_weekday_title(params['day']) # param day should be capitalized
    @greeting_message = GreetingMessage.find_by_venue_id_and_weekday_id(@venue.id, @day.id)
    
    respond_to do |format|
      get_params = params.require(:greeting_message).permit(:first_dj, :second_dj, :last_call, :admission_fee, :drink_special, :description)
      
      if @greeting_message.update_attributes(get_params)
        WebUser.mixpanel_event(current_web_user.id, 'View greeting message update', {
          'Day' => @day.weekday_title,
          'Venue' => (@venue.blank? ? '' : @venue.name)
        })
        format.html { redirect_to greeting_message_create_path(:id => @venue.id, :day => @day.weekday_title), notice: 'Greeting message was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @greeting_message.errors, status: :unprocessable_entity }
      end
    end
    
  end

  def show

  end

end