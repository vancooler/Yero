class UserAvatarsWorker
  include Sidekiq::Worker
  def perform(user_avatar_id)
    UserAvatar.find(user_avatar_id) do |user_avatar|
      # user_avatar.remote_image_url = url
      user_avatar.image_processing = nil
      user_avatar.save
    end
  end
end