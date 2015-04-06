class VenueAvatar < ActiveRecord::Base
  before_save :set_default_avatar_if_only_one_avatar_present
  # before_destroy :validate_min_number_of_avatars, :validate_cant_delete_default_avatar
  belongs_to :venue

  validates_presence_of :avatar
  # scope :main_avatar, -> {find_by(default:true)}
  # scope :secondary_avatars, -> {where.not(default:true)}
  
  # validate :max_number_of_avatars

  mount_uploader :avatar, VenueAvatarUploader
  # process_in_background :avatar
  
  # def update_image(image)
  #   self.avatar = image
  #   save!
  # end

  validate :avatar_number
 
  # before_create :randomize_file_name

  def name
    if self.venue.nil?

    else
      "Venue avatar for " + self.venue.name + " #" + self.id.to_s
    end
  end

  def avatar_number
    @avatar = VenueAvatar.where('venue_id = ?', self.venue_id)
    if @avatar.size >= 8
  
      errors.add :avatar, "You cannot upload more than 8 avatars for a same venue."
    end
  end
  

  def set_as_default
    VenueAvatar.where(venue_id: self.venue_id, default: true).each do |avatar|
      if avatar.id != self.id
        avatar.default = false
        avatar.save!
      end
    end
    self.default = true
    # if self.save!
    #   logger.info "CURRENT DEFAULT VALUE" + self.default.to_s
    # end
  end

  private

    def set_default_avatar_if_only_one_avatar_present
      set_default = false
      if !self.venue.nil?
        if (self.venue.venue_avatars.count < 1 || self.default == true)  
          set_default = true
        end 
      else
      end
      if set_default
        self.set_as_default
      end
    end

    # def max_number_of_avatars
    #   return unless user_id_changed?
    #   maximum_number_of_avatars = 3
    #   unless self.user.user_avatars.size < maximum_number_of_avatars
    #     errors.add :base, "You cannot have more than #{maximum_number_of_avatars} avatars."
    #     return false
    #   end
    # end

    # def validate_min_number_of_avatars
    #   minimum_number_of_avatars = 1
    #   unless self.user.user_avatars.size > minimum_number_of_avatars
    #     errors.add :base, "You cannot have less than #{minimum_number_of_avatars} avatars."
    #     return false
    #   end
    # end

    # def validate_cant_delete_default_avatar
    #   return unless self.default == true
    #   errors.add :base, "You cannot delete the default avatar."
    #   return false
    # end
end