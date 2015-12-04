class AdminUser < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, 
         :recoverable, :rememberable, :trackable, :validatable, :timeoutable

  has_many :admin_actions


  def name
  	email + " (" + id.to_s + ")"
  end
  def add_action(options = {})
  	action = AdminAction.new
  	action.action_type = options['action_type']
  	action.admin_user_id = self.id
  	action.details = options['details'] + "<br> Handled by " + self.email
    action.reason = options['reason'] || ''
    action.image_url = options['image_url'] || nil
    action.thumb_url = options['thumb_url'] || nil
  	action.save
  end
end
