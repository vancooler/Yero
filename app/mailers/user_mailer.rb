class UserMailer < ActionMailer::Base

  def forget_password(user)
  	@user = user
  	mail(to: @user.email, subject: "Password Recovery at Yero")
  end
end
