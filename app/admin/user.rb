ActiveAdmin.register User do
  menu :parent => "USERS"
  permit_params :email, :birthday, :gender, :apn_token, :wechat_id, :snapchat_id, :instagram_id,
                user_avatars_attributes: [:id, :avatar, :venue_id, :default, :is_active, :_destroy]

  actions :index, :show, :edit, :update, :destroy
  index do
  	column :id
    column :email
    column :key
    column :birthday
    column :first_name
    column :gender
    column :apn_token
    column :is_connected
    # column :position do |project|
    #  best_in_place project, :position, :type => :input,:path =>[:admin,project]
    # end

    # column :is_active
    
  	actions
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
      f.inputs do
        f.has_many :user_avatars, heading: 'Avatars', allow_destroy: false, new_record: false do |b|
          b.input :avatar, :image_preview => true, :style => "height:98px;width:98px;"
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
      row("Default Avatar ID") { |ad| link_to ad.default_avatar.id, [ :admin, ad.default_avatar ] if !ad.default_avatar.nil?}
      row("Default Avatar") { |ad| image_tag(ad.default_avatar.avatar.thumb.url, {:style => "height:98px;width:98px;"}) if !ad.default_avatar.nil?}

      table_for ad.secondary_avatars.order('id ASC') do
        column "Secondary Avatars ID" do |a|
          link_to a.id, [ :admin, a ]
        end
        column "Secondary Avatars" do |a|
          image_tag a.avatar.thumb.url, {:style => "height:98px;width:98px;"}
        end
      end

    end
  end
end
