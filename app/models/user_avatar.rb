class UserAvatar < ActiveRecord::Base
  after_save :set_default_avatar_if_only_one_avatar_present
  before_destroy :validate_min_number_of_avatars, :validate_cant_delete_default_avatar
  belongs_to :user
  
  validate :max_number_of_avatars

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
    self.default= true
    self.save
  end

  private

    def set_default_avatar_if_only_one_avatar_present
      return if (self.user.user_avatars.count > 1 || self.default == true)
      self.default = true
      self.save
    end

    def max_number_of_avatars
      return unless user_id_changed?
      maximum_number_of_avatars = 3
      unless self.user.user_avatars.size < maximum_number_of_avatars
        errors.add :base, "You cannot have more than #{maximum_number_of_avatars} avatars."
        return false
      end
    end

    def validate_min_number_of_avatars
      minimum_number_of_avatars = 1
      unless self.user.user_avatars.size > minimum_number_of_avatars
        errors.add :base, "You cannot have less than #{minimum_number_of_avatars} avatars."
        return false
      end
    end

    def validate_cant_delete_default_avatar
      return unless self.default == true
      errors.add :base, "You cannot delete the default avatar."
      return false
    end
end