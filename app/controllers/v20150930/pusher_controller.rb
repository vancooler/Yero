class PusherController < ApplicationController


  def auth
    if current_user
      auth = Pusher[params[:channel_name]].authenticate(params[:socket_id])

      render :text => params[:callback] + "(" + auth.to_json + ")", :content_type => 'application/javascript'
    else
      render :text => "Forbidden", :status => '403'
    end
  end

  def webhook_channel_exist
    webhook = Pusher.webhook(request)
    if webhook.valid?
      webhook.events.each do |event|
        case event["name"]
        when 'channel_occupied'
          puts "Channel occupied: #{event["channel"]}"
          channel = event["channel"]
          if channel.include? "private-user-"
            channel_array = channel.split "private-user-"
            if channel_array.count > 1 and channel_array[1].to_i > 0
              user = User.find_by_id(channel_array[1].to_i)
              if !user.nil?
                user.pusher_private_online
              end
            end
          end
        when 'channel_vacated'
          puts "Channel vacated: #{event["channel"]}"
          channel = event["channel"]
          if channel.include? "private-user-"
            channel_array = channel.split "private-user-"
            if channel_array.count > 1 and channel_array[1].to_i > 0
              user = User.find_by_id(channel_array[1].to_i)
              if !user.nil?
                user.pusher_private_offline
              end
            end
          end
        end
      end
      render text: 'ok'
    else
      render text: 'invalid', status: 401
    end
  end

end