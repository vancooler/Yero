class UserMailer < ActionMailer::Base

  def forget_password(user)
  	@user = user
  	mail(to: @user.email, subject: "Password Recovery at Yero")
  end

  def password_change_success(user)
  	@user = user
  	mail(to:@user.email, subject: "Password Successfully Changed.")
  end
end
