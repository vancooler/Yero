require 'aws-sdk'
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
  
  # :nocov:
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
  # :nocov:

  def self.order_minus_one(user_id, starting_order)
    greater_avatars = UserAvatar.where(user_id: user_id).where(is_active: true).where(order: (starting_order)..Float::INFINITY)
    greater_avatars.each do |ga|
      ga.order = ga.order - 1
      ga.save!
    end
  end

  # :nocov:
  def self.move_url
    avatars = UserAvatar.where("origin_url is ?", nil)
    avatars.each do |a|
      a.origin_url = a.avatar.url 
      a.thumb_url = a.avatar.thumb.url
      a.save
    end
  end

  def self.save_and_copy_url(avatar)
    if avatar.save
      avatar.origin_url = avatar.avatar.url
      avatar.thumb_url = avatar.avatar.thumb.url
      avatar.save
    end
  end
  # :nocov:

  def self.remove_from_aws(avatar_url, thumb_url)
    # remove in AWS
    # :nocov:
    if Rails.env == 'production'
      # if !ENV['AWS_ACCESS_KEY_ID'].blank?
      #   access_key_id = ENV['AWS_ACCESS_KEY_ID']
      # end
      # if !ENV['AWS_SECRET_ACCESS_KEY'].blank?
      #   access_key = ENV['AWS_SECRET_ACCESS_KEY']
      # end
      # if !ENV['S3_BUCKET_NAME'].blank?
      #   bucket = ENV['S3_BUCKET_NAME']
      # end
      # AWS.config(:access_key_id => access_key_id, :secret_access_key => access_key)
      s3 = AWS::S3.new

      array = avatar_url.split(bucket+'/')
      if array.count>1
        s3_bucket = s3.buckets[bucket]
        if s3_bucket
          object = s3_bucket.objects[array.last]
          if object
            response_1 = object.delete
          end
        end
      else
        array = avatar_url.split('amazonaws.com/uploads')
        if array.count > 1
          s3_bucket = s3.buckets[bucket]
          if s3_bucket
            object = s3_bucket.objects['uploads'+array.last]
            if object
              response_1 = object.delete
            end
          end
        end
      end
      array = thumb_url.split(bucket+'/')
      if array.count>1
        s3_bucket = s3.buckets[bucket]
        if s3_bucket
          object = s3_bucket.objects[array.last]
          if object
            response_2 = object.delete
          end
        end
      else
        array = thumb_url.split('amazonaws.com/uploads')
        if array.count > 1
          s3_bucket = s3.buckets[bucket]
          if s3_bucket
            object = s3_bucket.objects['uploads'+array.last]
            if object
              response_2 = object.delete
            end
          end
        end
      end
    end
    # :nocov:

    return [response_1, response_2]
  end
  private
    # :nocov:
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
    # :nocov:
end