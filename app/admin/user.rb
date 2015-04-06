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
    end
  end
end
