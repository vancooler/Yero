class UserAvatar < ActiveRecord::Base
  # A User has 1..n images

  belongs_to :user

  mount_uploader :avatar, AvatarUploader

  def update_image(image)
    self.avatar = image
    save!
  end
end