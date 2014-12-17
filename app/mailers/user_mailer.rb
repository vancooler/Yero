class UserMailer < ActionMailer::Base
  default from: "donaldlee50@gmail.com"

  def forget_password(user)
  	@user = user
  	mail(to: @user.email, subject: "Password Recovery at Yero")
  end
end
