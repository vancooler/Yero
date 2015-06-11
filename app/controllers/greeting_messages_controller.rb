class GreetingMessagesController < ApplicationController

  before_action :authenticate_web_user!, only: [:edit_message, :update]
  before_action :authenticate_admin_user!, only: [:approve]
  
  def approve
    @greeting_message = GreetingMessage.find(params[:greeting_message])
    @greeting_message.first_dj = @greeting_message.pending_first_dj
    @greeting_message.second_dj = @greeting_message.pending_second_dj
    @greeting_message.last_call = @greeting_message.pending_last_call
    @greeting_message.admission_fee = @greeting_message.pending_admission_fee
    @greeting_message.drink_special = @greeting_message.pending_drink_special
    @greeting_message.description = @greeting_message.pending_description
    @greeting_message.pending_first_dj = nil
    @greeting_message.pending_second_dj = nil
    @greeting_message.pending_last_call = nil
    @greeting_message.pending_admission_fee = nil
    @greeting_message.pending_drink_special = nil
    @greeting_message.pending_description = nil
    @greeting_message.draft_pending = false
    if @greeting_message.save!
      # change default poster
      if @greeting_message.greeting_posters.where(:default => false).count > 0
        if @greeting_message.greeting_posters.where(:default => true).count > 0 
          poster = @greeting_message.greeting_posters.where(:default => true).first
          poster.destroy
        end
        poster = @greeting_message.greeting_posters.where(:default => false).first
        poster.default = true
        poster.save!
      end

      # TODO: send email to webuser
      redirect_to admin_greeting_message_url(@greeting_message), :notice => "Pending draft approved!" 
    else
      redirect_to :back, :notice => "Something wrong..."
    end
  end

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
      @greeting_message.draft_pending = false
      @greeting_message.save
    else
      if @greeting_message.draft_pending.nil? or !@greeting_message.draft_pending
        @greeting_message.pending_first_dj = @greeting_message.first_dj
        @greeting_message.pending_second_dj = @greeting_message.second_dj
        @greeting_message.pending_last_call = @greeting_message.last_call
        @greeting_message.pending_last_call_as = @greeting_message.last_call_as
        @greeting_message.pending_admission_fee = @greeting_message.admission_fee
        @greeting_message.pending_drink_special = @greeting_message.drink_special
        @greeting_message.pending_description = @greeting_message.description
      end
    end
  end


  # save action
  def update
    # @venue = Venue.find_by_id(params['id'])
    # @day = Weekday.find_by_weekday_title(params['day']) # param day should be capitalized
    # @greeting_message = GreetingMessage.find_by_venue_id_and_weekday_id(@venue.id, @day.id)
    @greeting_message = GreetingMessage.find_by_id(params['id'])
    if !@greeting_message.nil?
      @venue = @greeting_message.venue
      @day = @greeting_message.weekday
      respond_to do |format|

        get_params = params.require(:greeting_message).permit(:pending_first_dj, :pending_second_dj, :pending_last_call, :pending_last_call_as, :pending_admission_fee, :pending_drink_special, :pending_description, :poster, :image)

        get_params[:pending_last_call] = params[:pending_last_call]
        get_params[:pending_last_call_as] = params[:pending_last_call_as]
        if params[:image_type].nil? or (params[:image_type] != "url" and params[:image_type] != "file")
          poster_update = false
        else
          poster_update = true
        end

        if poster_update
          greeting_posters = GreetingPoster.where(:greeting_message_id => @greeting_message.id).where(:default => false)
        
          if !get_params[:poster].blank? and params[:image_type] == "file"
            if greeting_posters.count > 0
              greeting_posters.first.update(avatar: get_params[:poster])
            else
              @greeting_message.greeting_posters.create(avatar: get_params[:poster], default: false)
            end
          elsif !params[:image].blank? and params[:image_type] == "url"
            image_url = ''
            image_url = Rails.env.production? ? params[:image] : 'http://localhost:3000' + params[:image]
            if greeting_posters.count > 0
              greeting_posters.first.update(remote_avatar_url: image_url)
            else
              @greeting_message.greeting_posters.create(remote_avatar_url: image_url, default: false)
            end
          else
            poster_update = false
          end

        end
        get_params.delete(:poster)


        if !@greeting_message.draft_pending.nil? and @greeting_message.draft_pending
          # has draft
          if @greeting_message.update_attributes(get_params)
            WebUser.mixpanel_event(current_web_user.id, 'Update the greeting message draft', {
                'Venue Name' => @venue.name,
                'Venue ID' => @venue.id.to_s
            })
            format.html { redirect_to greeting_message_create_path(:id => @venue.id, :day => @day.weekday_title), notice: 'Greeting message was successfully updated.' }
            format.json { head :no_content }
          else
            format.html { render action: "edit" }
            format.json { render json: @greeting_message.errors, status: :unprocessable_entity }
          end
        else
          # no draft
          if !poster_update and ((get_params[:pending_first_dj].blank? and @greeting_message.first_dj.blank?) or get_params[:pending_first_dj] == @greeting_message.first_dj) and ((get_params[:pending_second_dj].blank? and @greeting_message.second_dj.blank?) or get_params[:pending_second_dj].to_s == @greeting_message.second_dj) and ((get_params[:pending_last_call].blank? and @greeting_message.last_call.blank?) or get_params[:pending_last_call] == @greeting_message.last_call) and ((get_params[:pending_last_call_as].blank? and @greeting_message.last_call_as.blank?) or get_params[:pending_last_call_as] == @greeting_message.last_call_as) and ((get_params[:pending_admission_fee].blank? and @greeting_message.admission_fee.blank?) or get_params[:pending_admission_fee] == @greeting_message.admission_fee) and ((get_params[:pending_drink_special].blank? and @greeting_message.drink_special.blank?) or get_params[:pending_drink_special] == @greeting_message.drink_special) and ((get_params[:pending_description].blank? and @greeting_message.description.blank?) or get_params[:pending_description] == @greeting_message.description)
            # nothing changed
            @greeting_message.pending_first_dj = nil
            @greeting_message.pending_second_dj = nil
            @greeting_message.pending_last_call = nil
            @greeting_message.pending_last_call_as = nil
            @greeting_message.pending_admission_fee = nil
            @greeting_message.pending_drink_special = nil
            @greeting_message.pending_description = nil
            @greeting_message.draft_pending = false
            @greeting_message.save!

            format.html { redirect_to greeting_message_create_path(:id => @venue.id, :day => @day.weekday_title), notice: 'Sorry, nothing changed.' }
            format.json { head :no_content }

          else
            # something changed
            if @greeting_message.update_attributes(get_params)
              @greeting_message.draft_pending = true
              @greeting_message.save
              # TODO: send email to both admin(hello@yero.co) and webuser
              WebUser.mixpanel_event(current_web_user.id, 'Create a greeting message draft', {
                  'Venue Name' => @venue.name,
                  'Venue ID' => @venue.id.to_s
              })
              format.html { redirect_to greeting_message_create_path(:id => @venue.id, :day => @day.weekday_title), notice: 'Greeting message was successfully updated.' }
              format.json { head :no_content }
            else
              format.html { render action: "edit" }
              format.json { render json: @greeting_message.errors, status: :unprocessable_entity }
            end
          end 
        end
      end

    end
  end

  def show

  end

end