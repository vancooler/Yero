class UserAvatar < ActiveRecord::Base
  # A User has 1..n images
  after_save :set_default_avatar_if_only_one_avatar_present
  belongs_to :user
  
  validate :validate_max_avatars_have_not_been_reached

  mount_uploader :avatar, AvatarUploader

  def update_image(image)
    self.avatar = image
    save!
  end

  def set_as_default
    UserAvatar.where(user_id: self.user_id, default: true).each do |avatar|
      avatar.default = false
      avatar.save
    end
    self.update(default: true)
  end

  private

    def set_default_avatar_if_only_one_avatar_present
      return if (self.user.user_avatars.count >= 1 || self.default == true)
      self.update(default: true)
    end

    def validate_max_avatars_have_not_been_reached
      maximum_number_of_avatars = 3
      return unless user_id_changed? # nothing to validate
      errors.add_to_base("You cannot have more than #{maximum_number_of_avatars} avatars.") unless self.user.user_avatars.size < maximum_number_of_avatars
    end
end