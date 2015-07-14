ActiveAdmin.register UserAvatar  do
  menu :parent => "USERS", :label => "User Screening"
  permit_params :user, :default, :avatar, :user_id, :is_active
  config.per_page = 100
  actions :index, :show
  batch_action :destroy, false

  controller do
    def disable_single_image
      ua = UserAvatar.find_by_id(params[:id])
      if !ua.nil?
        ua.is_active = false
        if ua.save! and !ua.user_id.nil?
          u = User.find_by_id(ua.user_id)
          if !u.blank? 
            # disconnect user
            default = 0
            if ua.default
              u.leave_network
              default = 1
            end
            # notification
            WhisperNotification.send_avatar_disabled_notification(ua.user_id, default)
            ReportUserHistory.notify_all_users(ua.user_id)
          end
        end
      end
      redirect_to :back, :notice => "Image is disabled"
    end

    def enable_single_image
      ua = UserAvatar.find_by_id(params[:id])
      if !ua.nil?
        ua.is_active = true
        ua.save!
      end
      redirect_to :back, :notice => "Image is enabled"
    end

    def disable_single_user
      ua = UserAvatar.find_by_id(params[:id])
      if !ua.nil? and !ua.user.nil?
        user = ua.user
        user.account_status = 0
        user.save!
      end
      redirect_to :back, :notice => "User is disabled"
    end

    def enable_single_user
      ua = UserAvatar.find_by_id(params[:id])
      if !ua.nil? and !ua.user.nil?
        user = ua.user
        user.account_status = 1
        user.save!
      end
      redirect_to :back, :notice => "User is enabled"
    end
  end 

  batch_action :disable_image, :confirm => "Are you sure you want to disable all of these images?" do |selection|
    UserAvatar.find(selection).each do |ua|
      ua.is_active = false
      if ua.save! and !ua.user_id.nil?
        u = User.find_by_id(ua.user_id)
        if !u.blank? 
          # disconnect user
          default = 0
          if ua.default
            u.leave_network
            default = 1
          end
          # notification
          WhisperNotification.send_avatar_disabled_notification(ua.user_id, default)
          ReportUserHistory.notify_all_users(ua.user_id)
        end
      end
    end
    redirect_to :back, :notice => "Selected images are disabled"
  end
  batch_action :enable_image, :confirm => "Are you sure you want to enable all of these images?" do |selection|
    UserAvatar.find(selection).each do |ua|
      ua.is_active = true
      ua.save!
    end
    redirect_to :back, :notice => "Selected images are enabled"
  end
  batch_action :disable_user_account, :confirm => "Are you sure you want to disable all of these users?" do |selection|
    UserAvatar.find(selection).each do |ua|
      user = ua.user
      if !user.nil?
        user.account_status = 0
        user.save!
      end
    end
    redirect_to :back, :notice => "Selected users are disable"
  end
  batch_action :enable_user_account, :confirm => "Are you sure you want to enable all of these users?" do |selection|
    UserAvatar.find(selection).each do |ua|
      user = ua.user
      if !user.nil?
        user.account_status = 1
        user.save!
      end
    end
    redirect_to :back, :notice => "Selected users are enabled"
  end
  index do
    selectable_column
  	column :id
    column "Image", :avatar do |avatar|
      link_to avatar.avatar.url, :target => "_blank" do 
        image_tag avatar.avatar.thumb.url, {:style => "height:100px;width:100px;"}
      end
    end
    column "User (ID)", :user
    column "Gender", :user do |ua|
      ua.user.nil? ? '' : ua.user.gender
    end
    column "Age", :user do |ua|
      ua.user.nil? ? '' : ua.user.age
    end
    column "Email", :user do |ua|
      ua.user.nil? ? '' : ua.user.email
    end
    column "Snapchat", :user do |ua|
      ua.user.nil? ? '' : ua.user.snapchat_id
    end
    column "Wechat", :user do |ua|
      ua.user.nil? ? '' : ua.user.wechat_id
    end
    column "Instagram", :user do |ua|
      ua.user.nil? ? '' : ua.user.instagram_id
    end
    column "Line", :user do |ua|
      ua.user.nil? ? '' : ua.user.line_id
    end
    # column "Is default", :default
    column "Avatar Enabled", :is_active
    column "Account Status", :user do |ua|
      ua.user.nil? ? '' : (ua.user.account_status == 0 ? raw('<span class="status_tag no">Disabled</span>') : raw('<span class="status_tag yes">Active</span>'))
    end
    column "Actions", :actions do |ua|
      link_to("Disable Image", admin_disable_single_image_path(ua), :class => "member_link button small", :method => "post", :data => {:confirm => "Are you sure you want to disable this image?"}) + link_to("Enable Image", admin_enable_single_image_path(ua), :class => "member_link button small", :method => "post", :data => {:confirm => "Are you sure you want to enable this image?"}) + link_to("Disable User", admin_disable_user_account_path(ua), :class => "member_link button small", :method => "post", :data => {:confirm => "Are you sure you want to disable this user?"}) + link_to("Enable User", admin_enable_user_account_path(ua), :class => "member_link button small", :method => "post", :data => {:confirm => "Are you sure you want to enable this user?"})
    end
    
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
      row "Image" do image_tag user.avatar.thumb.url, {:style => "height:100px;width:100px;"} end
          
      row :default
      row "Enabled" do user.is_active end
    end
  end
end
