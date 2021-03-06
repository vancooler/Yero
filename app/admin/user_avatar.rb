ActiveAdmin.register UserAvatar, :as => "User Screening" do
  menu :parent => "USERS"
  permit_params :user, :default, :avatar, :user_id, :is_active
  config.per_page = 100
  actions :index, :show
  batch_action :destroy, false
  config.action_items.delete_if { |item|
    # item is an ActiveAdmin::ActionItem
    item.display_on?(:index)
  }


  controller do
    def scoped_collection
      super.includes(:user) # prevents N+1 queries to your database
    end
    def disable_single_image
      ua = UserAvatar.find_by_id(params[:id])
      avatar_id = ua.id
      if !ua.nil?
        ua.is_active = false
        if ua.save! and !ua.user_id.nil?
          u = User.find_user_by_unique(ua.user_id)
          if !u.blank? 
            u.avatar_disabled_count = u.avatar_disabled_count.nil? ? 1 : u.avatar_disabled_count+1
            u.save
            # disconnect user
            default = 0
            UserAvatar.order_minus_one(u.id, ua.order)
            if u.user_avatars.where(:is_active => true).blank?
              u.leave_network
              default = 1

            end
            action_type = "Disable user's photo"
            details = "Photo with id: " + ua.id.to_s
            current_admin_user.add_action({'action_type' => action_type, 'details' => details})

            # WhisperNotification.create_in_aws(u.id, nil, nil, '101', 'No Active Photo Now')
            RecentActivity.add_activity(u.id, '101', nil, nil, "avatar-disabled-"+u.id.to_s+"-"+Time.now.to_i.to_s)
    
            if u.pusher_private_online
              u.pusher_delete_photo_event(avatar_id)
            else
              if Rails.env == "production"
                WhisperNotification.delay.send_avatar_disabled_notification(ua.user_id, default)
              end
            end
            # notification
            ReportUserHistory.mark_as_notified(ua.user_id)
          end
        end
      end
      redirect_to :back, :notice => "Image is disabled"
    end

    def enable_single_image
      ua = UserAvatar.find_by_id(params[:id])
      if !ua.nil?
        ua.is_active = true
        current_order = UserAvatar.where(:user_id => ua.user_id).where(:is_active => true).maximum(:order)
      next_order = current_order.nil? ? 0 : current_order+1
      ua.order = next_order
        ua.save!
        action_type = "Enable user's photo"
        details = "Photo with id: " + ua.id.to_s
        current_admin_user.add_action({'action_type' => action_type, 'details' => details})
      end
      redirect_to :back, :notice => "Image is enabled"
    end

    def remove_snapchat
      user = User.find_user_by_unique(params[:id])
      if !user.nil?
        if user.update(:snapchat_id => '')
          redirect_to :back, :notice => "Snapchat id of user " + user.name + " was successfully removed."
        else
          redirect_to :back, :notice => "Failed to remove Snapchat id of user " + user.name 
        end
      else
        redirect_to :back, :notice => "Cannot find the user" 
      end
    end

    def remove_wechat
      user = User.find_user_by_unique(params[:id])
      if !user.nil?
        if user.update(:wechat_id => '')
          redirect_to :back, :notice => "Wechat id of user " + user.name + " was successfully removed."
        else
          redirect_to :back, :notice => "Failed to remove Wechat id of user " + user.name 
        end
      else
        redirect_to :back, :notice => "Cannot find the user" 
      end
    end

    def remove_line
      user = User.find_user_by_unique(params[:id])
      if !user.nil?
        if user.update(:line_id => '')
          redirect_to :back, :notice => "Line id of user " + user.name + " was successfully removed."
        else
          redirect_to :back, :notice => "Failed to remove Line id of user " + user.name 
        end
      else
        redirect_to :back, :notice => "Cannot find the user" 
      end
    end

    def remove_status
      user = User.find_user_by_unique(params[:id])
      if !user.nil?
        details = user.introduction_2
        if user.update(:introduction_2 => '', :status_disabled_count => user.status_disabled_count+1)
          action_type = "Delete user's status"
          current_admin_user.add_action({'action_type' => action_type, 'details' => details})

          redirect_to :back, :notice => "Status of user " + user.name + " was successfully removed."
        else
          redirect_to :back, :notice => "Failed to remove status of user " + user.name 
        end
      else
        redirect_to :back, :notice => "Cannot find the user" 
      end
    end

    # def disable_single_user
    #   ua = UserAvatar.find_by_id(params[:id])
    #   if !ua.nil? and !ua.user.nil?
    #     user = ua.user
    #     user.account_status = 0
    #     user.save!
    #   end
    #   redirect_to :back, :notice => "User is disabled"
    # end

    # def enable_single_user
    #   ua = UserAvatar.find_by_id(params[:id])
    #   if !ua.nil? and !ua.user.nil?
    #     user = ua.user
    #     user.account_status = 1
    #     user.save!
    #   end
    #   redirect_to :back, :notice => "User is enabled"
    # end
  end 

  batch_action :disable_image, :confirm => "Are you sure you want to disable all of these images?" do |selection|
    UserAvatar.find(selection).each do |ua|
      ua.is_active = false
      if ua.save! and !ua.user_id.nil?
        u = User.find_user_by_unique(ua.user_id)
        if !u.blank? 
          u.avatar_disabled_count = u.avatar_disabled_count.nil? ? 1 : u.avatar_disabled_count+1
          u.save
          # disconnect user
          default = 0
          UserAvatar.order_minus_one(u.id, ua.order)
          if u.user_avatars.where(:is_active => true).blank?
            u.leave_network
            default = 1

          end
          action_type = "Disable user's photo"
          details = "Photo with id: " + ua.id.to_s
          current_admin_user.add_action({'action_type' => action_type, 'details' => details})
          # WhisperNotification.create_in_aws(u.id, nil, nil, '101', 'No Active Photo Now')
          RecentActivity.add_activity(u.id, '101', nil, nil, "avatar-disabled-"+u.id.to_s+"-"+Time.now.to_i.to_s)
          if u.pusher_private_online
            u.pusher_delete_photo_event
          else
            if Rails.env == "production"
              WhisperNotification.delay.send_avatar_disabled_notification(ua.user_id, default)
            end
          end
          ReportUserHistory.mark_as_notified(ua.user_id)
        end
      end
    end
    redirect_to :back, :notice => "Selected images are disabled"
  end
  batch_action :enable_image, :confirm => "Are you sure you want to enable all of these images?" do |selection|
    UserAvatar.find(selection).each do |ua|
      ua.is_active = true
      current_order = UserAvatar.where(:user_id => ua.user_id).where(:is_active => true).maximum(:order)
      next_order = current_order.nil? ? 0 : current_order+1
      ua.order = next_order
      ua.save!
      action_type = "Enable user's photo"
      details = "Photo with id: " + ua.id.to_s
      current_admin_user.add_action({'action_type' => action_type, 'details' => details})
    end
    redirect_to :back, :notice => "Selected images are enabled"
  end
  # batch_action :disable_user_account, :confirm => "Are you sure you want to disable all of these users?" do |selection|
  #   UserAvatar.find(selection).each do |ua|
  #     user = ua.user
  #     if !user.nil?
  #       user.account_status = 0
  #       user.save!
  #     end
  #   end
  #   redirect_to :back, :notice => "Selected users are disable"
  # end
  # batch_action :enable_user_account, :confirm => "Are you sure you want to enable all of these users?" do |selection|
  #   UserAvatar.find(selection).each do |ua|
  #     user = ua.user
  #     if !user.nil?
  #       user.account_status = 1
  #       user.save!
  #     end
  #   end
  #   redirect_to :back, :notice => "Selected users are enabled"
  # end
  index do
    selectable_column
  	column :id
    column "Image", :avatar do |avatar|
      link = link_to avatar.origin_url, :target => "_blank" do 
        image_tag avatar.thumb_url, {:style => "height:100px;width:100px;"}
      end
      link + ((avatar.is_active.nil? or avatar.order.nil?) ? '' : ((avatar.is_active == false or avatar.order.to_i != 0) ? '' : raw('<span class="status_tag yes">P</span>')))
    end
    column "User (ID)", :user
    # column "Gender", :user do |ua|
    #   ua.user.nil? ? '' : ua.user.gender
    # end
    # column "Age", :user do |ua|
    #   ua.user.nil? ? '' : ua.user.age
    # end
    # column "Email", :user do |ua|
    #   ua.user.nil? ? '' : ua.user.email
    # end
    # column "Instagram", :user do |ua|
    #   ua.user.nil? ? '' : ua.user.instagram_id
    # end
    column "Status", :user do |ua|
      (ua.user.blank? or ua.user.introduction_2.blank?) ? '' : raw(link_to(image_tag('delete.png', :style => "width:18px;height:18px;margin-right:6px;"), admin_remove_status_path(ua.user.id), :method => 'put', :data => {:confirm => "Are you sure?"}) + ua.user.introduction_2)
    end

    column "Status Disabled Count", :user do |ua|
      (ua.user.blank? or ua.user.status_disabled_count.blank?) ? 0 : ua.user.status_disabled_count
    end


    # column "Snapchat", :user do |ua|
    #   (ua.user.blank? or ua.user.snapchat_id.blank?) ? '' : raw(link_to(image_tag('delete.png', :style => "width:18px;height:18px;margin-right:6px;"), admin_remove_snapchat_id_path(ua.user.id), :method => 'put', :data => {:confirm => "Are you sure?"}) + ua.user.snapchat_id)
    # end
    # column "Wechat", :user do |ua|
    #   (ua.user.blank? or ua.user.wechat_id.blank?) ? '' : raw(link_to(image_tag('delete.png', :style => "width:18px;height:18px;margin-right:6px;"), admin_remove_wechat_id_path(ua.user.id), :method => 'put', :data => {:confirm => "Are you sure?"}) + ua.user.wechat_id)
    # end
    # column "Line", :user do |ua|
    #   (ua.user.blank? or ua.user.line_id.blank?) ? '' : raw(link_to(image_tag('delete.png', :style => "width:18px;height:18px;margin-right:6px;"), admin_remove_line_id_path(ua.user.id), :method => 'put', :data => {:confirm => "Are you sure?"}) + ua.user.line_id)
    # end
    # column "Is default", :default
    column "Image Enabled", :user do |ua|
      ua.is_active.nil? ? '' : (ua.is_active == false ? raw('<span class="status_tag no">Disabled</span>') : raw('<span class="status_tag yes">Active</span>'))
    end
    column "Image Disabled Count", :user do |ua|
      ua.user.nil? ? 0 : (ua.user.avatar_disabled_count.nil? ? 0 : ua.user.avatar_disabled_count)
    end
    # column "Account Status", :user do |ua|
    #   ua.user.nil? ? '' : (ua.user.account_status == 0 ? raw('<span class="status_tag no">Disabled</span>') : raw('<span class="status_tag yes">Active</span>'))
    # end
    column "Actions", :actions do |ua|
      link_to("Disable Image", admin_disable_single_image_path(ua), :class => "member_link button small", :method => "post", :data => {:confirm => "Are you sure you want to disable this image?"}) + link_to("Enable Image", admin_enable_single_image_path(ua), :class => "member_link button small", :method => "post", :data => {:confirm => "Are you sure you want to enable this image?"}) #+ link_to("Disable User", admin_disable_user_account_path(ua), :class => "member_link button small", :method => "post", :data => {:confirm => "Are you sure you want to disable this user?"}) + link_to("Enable User", admin_enable_user_account_path(ua), :class => "member_link button small", :method => "post", :data => {:confirm => "Are you sure you want to enable this user?"})
    end
    
  end
  filter :id
  # filter :user_id, label:      'User', as: :select, collection: User.includes(:user_avatars).where.not(user_avatars: { id: nil }).order(:id).reverse 
  filter :user_id, label:      'User ID'

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
      row "Image" do image_tag user.thumb_url, {:style => "height:100px;width:100px;"} end
          
      row :default
      row "Enabled" do user.is_active end
    end
  end
end
