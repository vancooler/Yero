class UserAvatar < ActiveRecord::Base
  # A User has 1..n images
  before_save :set_default_avatar_if_only_one_avatar_present

  belongs_to :user

  mount_uploader :avatar, AvatarUploader

  def update_image(image)
    self.avatar = image
    save!
  end

  private

  def set_as_default
    self.user.avatars{|avatar| avatar.update(default: false)}
    self.update(default: true)
  end

  def set_default_avatar_if_only_one_avatar_present
    self.default = true if self.user.user_avatars.count <= 1
  end
end