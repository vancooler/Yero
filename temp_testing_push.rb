require 'houston'

# Environment variables are automatically read, or can be overridden by any specified options. You can also
# conveniently use `Houston::Client.development` or `Houston::Client.production`.

app_local_path = "/home/alex/sites/yero/purpleoctopus-staging"

APN = Houston::Client.development
APN.certificate = File.read("#{app_local_path}/apple_push_notification.pem")

# An example of the token sent back when a device registers for notifications
token = "<443e69367fbbbce9c722fdf392f72af2111bde5626a916007d97382687d4b029>"
# Create a notification that alerts a message to the user, plays a sound, and sets the badge on the app
notification = Houston::Notification.new(device: token)
notification.alert = "Hi YJ!!! Have a great weekend!"

# Notifications can also change the badge count, have a custom sound, have a category identifier, indicate available Newsstand content, or pass along arbitrary data.
notification.badge = 57
notification.sound = "sosumi.aiff"
notification.category = "INVITE_CATEGORY"
notification.content_available = true
notification.custom_data = {foo: "bar"}

# And... sent! That's all it takes.
APN.push(notification)