class PusherController < ApplicationController
  def webhook_channel_exist
    webhook = Pusher.webhook(request)
    if webhook.valid?
      puts webhook.events.count.to_s + ' events'
      webhook.events.each do |event|
        case event["name"]
        when 'channel_occupied'
          puts "Channel occupied: #{event["channel"]}"
          channel = event["channel"]
          if channel.include? "private-user-"
            channel_array = channel.split "private-user-"
            if channel_array.count > 1 and channel_array[1].to_i > 0
              user = User.find_user_by_unique(channel_array[1].to_i)
              if !user.nil?
                user.pusher_private_online = true
                user.save
              end
            end
          end
        when 'channel_vacated'
          puts "Channel vacated: #{event["channel"]}"
          channel = event["channel"]
          if channel.include? "private-user-"
            channel_array = channel.split "private-user-"
            if channel_array.count > 1 and channel_array[1].to_i > 0
              user = User.find_user_by_unique(channel_array[1].to_i)
              if !user.nil?
                user.pusher_private_offline = false
                user.save
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