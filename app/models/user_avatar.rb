class UserAvatar < ActiveRecord::Base
  # A User has 1..n images
  before_save :set_default_avatar

  belongs_to :user

  mount_uploader :avatar, AvatarUploader

  def update_image(image)
    self.avatar = image
    save!
  end

  private

  def set_default_avatar
    self.default = true if self.user.user_avatars.count <= 1
  end
end