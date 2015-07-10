ActiveAdmin.register UserAvatar do
  menu :parent => "USERS"
  permit_params :user, :default, :avatar, :user_id, :is_active
  config.per_page = 100
  actions :index, :show
  batch_action :destroy, false
  batch_action :disable, :confirm => "Are you sure you want to disable all of these avatars?" do |selection|
    UserAvatar.find(selection).each do |ua|
      ua.is_active = false
      if ua.save! and !ua.user_id.nil?
        u = User.find_by_id(ua.user_id)
        if !u.blank? 
          # disconnect user
          default = 0
          if ua.default
            u.is_connected = false
            default = 1
          end
          u.save
          # notification
          WhisperNotification.send_avatar_disabled_notification(ua.user_id, default)
          ReportUserHistory.notify_all_users(ua.user_id)
        end
      end
    end
    redirect_to :back, :notice => "Selected avatars are disabled"
  end
  batch_action :enable, :confirm => "Are you sure you want to enable all of these avatars?" do |selection|
    UserAvatar.find(selection).each do |ua|
      ua.is_active = true
      ua.save!
    end
    redirect_to :back, :notice => "Selected avatars are enabled"
  end
  index do
    selectable_column
  	column :id
    column :avatar do |avatar|
      link_to avatar.avatar.url, :target => "_blank" do 
        image_tag avatar.avatar.thumb.url, {:style => "height:100px;width:100px;"}
      end
    end
    column "User (ID)", :user
    column "Is default", :default
    column :is_active
    actions
  end
  filter :id
  # filter :user_id, label:      'User', as: :select, collection: User.includes(:user_avatars).where.not(user_avatars: { id: nil }).order(:id).reverse 
  # filter :user

  filter :default
  filter :is_active
  filter :updated_at

  # form do |f|
  #   f.inputs "Details" do
  #     f.input :user
  #     f.input :avatar
  #     f.input :default
      
  #   end
  #   f.actions
  # end

  show do |user|
    attributes_table_for user do
      row :user
      row :avatar do
          image_tag user.avatar.thumb.url, {:style => "height:100px;width:100px;"}
      end
      row :default
    end
  end
end
