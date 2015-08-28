ActiveAdmin.register User do
  menu :parent => "USERS"
  permit_params :email, :birthday, :gender, :apn_token, :wechat_id, :snapchat_id, :instagram_id,
                user_avatars_attributes: [:id, :avatar, :venue_id, :default, :is_active, :_destroy]

  config.per_page = 100
  actions :index, :show, :edit, :update, :destroy

  action_item :only => :index, :if => proc { !current_admin_user.level.nil? and current_admin_user.level == 0 } do 
    link_to('CSV IMPORT', admin_import_users_csv_url)

  end

  action_item :only => :index, :if => proc { !current_admin_user.level.nil? and current_admin_user.level == 0 and ENV['DYNAMODB_PREFIX'] != 'Production'} do 
    link_to('Test Whisper', admin_send_whisper_url)

  end

  controller do
    def join_network
      user = User.find_by_id(params[:id])
      if !user.nil? and !user.is_connected
        user.join_network

        gate_number = 4
        # if set in db, use the db value
        if GlobalVariable.exists? name: "min_ppl_size"
          size = GlobalVariable.find_by_name("min_ppl_size")
          if !size.nil? and !size.value.nil? and size.value.to_i > 0
            gate_number = size.value.to_i
          end
        end

        all_users = user.fellow_participants(nil, 0, 100, nil, 0, 60, true)
        number_of_users = all_users.length + 1
        if number_of_users >= gate_number
          user.enough_user_notification_sent_tonight = true
          user.save
        end
      end
      redirect_to :back, :notice => "User is joined"
    end


    def leave_network
      user = User.find_by_id(params[:id])
      if !user.nil? and user.is_connected
        User.leave_activity([user.id])
        user.leave_network
      end
      redirect_to :back, :notice => "User is left"
    end

    def send_whisper
      user = User.find_by_id(params[:id])
      if !user.nil?
        origin_user = loop do
          offset = rand(User.count)
          rand_user = User.offset(offset).first
          break rand_user unless (rand_user.user_avatars.where(:is_active => true).count <= 0 or BlockUser.check_block(rand_user.id, user.id) or WhisperToday.where(target_user_id: user.id, origin_user_id: rand_user.id).count > 0)
        end

        WhisperNotification.send_whisper(user.id.to_s, origin_user, 0, '2', 'Here is static message generated by server', origin_user.first_name + " just sent you a whisper" )
      end
      redirect_to :back, :notice => "Whisper is sent"
    end


  end
  index do
  	column :id
    column :email
    column :birthday
    column :first_name
    column :gender
    column :is_connected
    # column :position do |project|
    #  best_in_place project, :position, :type => :input,:path =>[:admin,project]
    # end

    # column :is_active
    
  	# actions
    column "Actions", :actions do |user|
      link_to("Join network", admin_user_join_path(user), :class => "member_link button small", :method => "post", :data => {:confirm => "Are you sure you want to simulate this join?"}) + link_to("Leave network", admin_user_leave_path(user), :class => "member_link button small", :method => "post", :data => {:confirm => "Are you sure you want to simulate this leave?"}) + link_to("Send whisper", admin_user_send_whisper_path(user), :class => "member_link button small", :method => "post", :data => {:confirm => "Are you sure you want to simulate this whisper?"})

    end
  end

  filter :id
  filter :email
  filter :gender
  filter :is_connected

  form do |f|
    f.semantic_errors
    f.inputs "Details" do
      f.input :email
      # f.input :avatar, :image_preview => true
      f.input :first_name
      f.input :birthday
      f.input :gender, :as => :select, :collection => ['F', 'M']
      f.input :apn_token
      f.input :line_id
      f.input :wechat_id
      f.input :snapchat_id
      f.input :instagram_id
      f.input :introduction_1, :label => "Intrduction"
      f.inputs do
        f.has_many :user_avatars, heading: 'Avatars', allow_destroy: false, new_record: false do |b|
          b.input :avatar, :image_preview => true, :style => "height:100px;width:100px;"
          b.input :default
          # b.input :is_active
        end
      end
      
    end
    f.actions
  end
  

  show do |ad|
    attributes_table_for ad do
      row :email
      row :key
      row :birthday
      row :first_name
      row :gender
      row :apn_token
      row :is_connected
      row :snapchat_id
      row :line_id
      row :wechat_id
      row :instagram_id
      row("Intrduction") { |ad| ad.introduction_1}
      row("Default Avatar ID") { |ad| ad.default_avatar.id if !ad.default_avatar.nil?}
      row("Default Avatar") { |ad| image_tag(ad.default_avatar.avatar.thumb.url, {:style => "height:100px;width:100px;"}) if !ad.default_avatar.nil?}

      table_for ad.secondary_avatars.order('id ASC') do
        column "Secondary Avatars ID" do |a|
          a.id
        end
        column "Secondary Avatars" do |a|
          image_tag a.avatar.thumb.url, {:style => "height:100px;width:100px;"}
        end
      end

    end
  end
end
