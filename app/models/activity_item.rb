class ActivityItem
  def initialize(user, trackable, action = params[:action])
    @user_id = user.id
    @tackable = trackable
    @action = action
  end
  def create
    Activity.create(user_id: @user_id, trackable: @trackable, action: @action)
  end
end