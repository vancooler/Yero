ActiveAdmin.register User do
  menu :parent => "USERS"

  actions :index, :show
  index do
  	column :id
    column :email
    column :key
    column :birthday
    column :first_name
    column :gender
    column :apn_token
    column :account_status
    column :is_connected
    # column :position do |project|
    #  best_in_place project, :position, :type => :input,:path =>[:admin,project]
    # end

    # column :is_active
    
  	actions
  end
  

  show do |ad|
    attributes_table_for ad do
      row :email
      row :key
      row :birthday
      row :first_name
      row :gender
      row :apn_token
      row :snapchat_id
      row :wechat_id
      row :instagram_id
      row("Default Avatar ID") { |ad| link_to ad.default_avatar.id, [ :admin, ad.default_avatar ] if !ad.default_avatar.nil?}
      row("Default Avatar") { |ad| image_tag(ad.default_avatar.avatar) if !ad.default_avatar.nil?}

      table_for ad.secondary_avatars.order('id ASC') do
        column "Secondary Avatars ID" do |a|
          link_to a.id, [ :admin, a ]
        end
        column "Secondary Avatars" do |a|
          image_tag(a.avatar)
        end
      end

    end
  end
end
