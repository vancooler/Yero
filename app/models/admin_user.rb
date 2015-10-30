class AdminUser < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, 
         :recoverable, :rememberable, :trackable, :validatable, :timeoutable

  has_many :admin_actions


  def name
  	email + " (" + id.to_s + ")"
  end
  def add_action(action_type, details, reason)
  	action = AdminAction.new
  	action.action_type = action_type
  	action.admin_user_id = self.id
  	action.details = details + "<br> Handled by " + self.email
  	action.reason = reason
  	action.save
  end
end
