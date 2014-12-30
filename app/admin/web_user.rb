ActiveAdmin.register WebUser do
  actions :index, :show
  index do
  	column :id
    column :email
    column :web_user_name
    column :city
    column :venue_name
    column :job_title
    column :business_phone
    # column :position do |project|
    #  best_in_place project, :position, :type => :input,:path =>[:admin,project]
    # end

    # column :is_active
    
  	actions
  end
  filter :city, :label => "City", :as => :select, :collection => proc { WebUser.all.collect  { |c| [c.city] }.uniq }
  

  show do |ad|
    attributes_table_for ad do
      row :email
      row :web_user_name
      row :city
      row :venue_name 
      row :job_title 
      row :business_phone 
    end
  end
end
