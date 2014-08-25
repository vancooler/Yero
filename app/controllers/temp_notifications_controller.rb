class TempNotificationsController < ApplicationController
  def new
    @users = User.all
    @target_user = User.find_by(apn_token: "<443e69367fbbbce9c722fdf392f72af2111bde5626a916007d97382687d4b029>")
  end

  def create
    # RestClient.post('http://localhost:3000/api/v1/whisper/create',
    RestClient.post('http://purpleoctopus-staging.herokuapp.com/api/v1/whisper/create',
        {
            key: User.all.sample.key,
            target_id: User.all.sample.id
        }
    )
    render :new
  end
end
