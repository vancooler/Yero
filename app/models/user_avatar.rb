class UserAvatar < ActiveRecord::Base

  belongs_to :user

  mount_uploader :avatar, AvatarUploader

  def update_image(image)
    self.avatar = image
    save!
  end
end