class UserMailer < ActionMailer::Base
  # default to: '"Yero" <hello@yero.co>'

  def forget_password(user)
  	@user = user
  	mail(to: @user.email, subject: "Password Recovery at Yero")
  end

  def email_reset(user)
    @user = user
    mail(to: @user.email, subject: "Yero Email Address Confirmation")
  end

  def password_change_success(user)
  	@user = user
  	mail(to:@user.email, subject: "Password Successfully Changed.")
  end

  def venue_info_pending(web_user, venue)
  	@web_user = web_user
  	@venue = venue
  	@to = @web_user.nil? ? '"Yero" <hello@yero.co>' : @web_user.email
  	mail(to:@to, subject: "Your update for " + @venue.name + " is pending now.")
  	# mail(to:'"Yero" <hello@yero.co>' , subject: "Update for " + @venue.name + " is pending now.")
  end

  def venue_greeting_message_pending(web_user, venue)
  	@web_user = web_user
  	@venue = venue
  	@to = @web_user.nil? ? '"Yero" <hello@yero.co>' : @web_user.email
  	mail(to:@to, subject: "Your update for the greeting messages of " + @venue.name + " is pending now.")
  	# mail(to:'"Yero" <hello@yero.co>' , subject: "Update for the greeting messages of " + @venue.name + " is pending now.")
  end

  def venue_info_approved(web_user, venue)
  	@web_user = web_user
  	@venue = venue
  	mail(to:@web_user.email, subject: "Your update for " + @venue.name + " is approved now.")
  end

  def venue_greeting_message_approved(web_user, venue)
  	@web_user = web_user  	
  	@venue = venue
  	mail(to:@web_user.email, subject: "Your update for the greeting messages of " + @venue.name + " is approved now.")
  end
end
