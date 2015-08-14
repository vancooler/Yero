class UserAvatar < ActiveRecord::Base
  after_save :set_order_zero_if_only_one_avatar_present
  before_destroy :validate_min_number_of_avatars
  belongs_to :user
  scope :main_avatar, -> {find_by(order:0)}
  scope :secondary_avatars, -> {where.not(order:0)}
  
  validate :max_number_of_avatars

  mount_uploader :avatar, AvatarUploader
  # process_in_background :avatar
  # store_in_background :avatar
  
  def update_image(image)
    self.avatar = image
    save!
  end

  def set_as_default
    UserAvatar.where(user_id: self.user_id, default: true).each do |avatar|
      if avatar.id != self.id
        avatar.default = false
        avatar.save
      end
    end
    self.default = true
    if self.save!
      logger.info "CURRENT DEFAULT VALUE" + self.default.to_s
    end
  end

  def self.order_minus_one(user_id, starting_order)
    greater_avatars = UserAvatar.where(user_id: user_id).where(is_active: true).where(order: (starting_order)..Float::INFINITY)
    greater_avatars.each do |ga|
      ga.order = ga.order - 1
      ga.save!
    end
  end

  def self.move_url
    avatars = UserAvatar.where("origin_url is ?", nil)
    avatars.each do |a|
      a.origin_url = a.avatar.url 
      a.thumb_url = a.avatar.thumb.url
      a.save
    end
  end

  private

    def set_order_zero_if_only_one_avatar_present
      if !self.user.nil?
        return if (self.user.user_avatars.where(:is_active => true).count > 1 || self.order == 0)   
      else
        return
      end
      self.order = 0
      self.save
    end

    def max_number_of_avatars
      return unless user_id_changed?
      maximum_number_of_avatars = 6
      unless self.user.user_avatars.where(:is_active => true).size < maximum_number_of_avatars
        errors.add :base, "You cannot have more than #{maximum_number_of_avatars} avatars."
        return false
      end
    end

    def validate_min_number_of_avatars
      minimum_number_of_avatars = 0
      unless self.user.user_avatars.where(:is_active => true).size > minimum_number_of_avatars
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