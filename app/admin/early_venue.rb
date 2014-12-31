ActiveAdmin.register EarlyVenue do
  actions :index, :show
  index do
  	column :id
    column :email
    column :username
    column :city
    column :venue_name
    column :job_title
    column :phone
    # column :position do |project|
    #  best_in_place project, :position, :type => :input,:path =>[:admin,project]
    # end

    # column :is_active
    
  	actions
  end
  filter :city, :label => "City", :as => :select, :collection => proc { EarlyVenue.all.collect  { |c| [c.city] }.uniq }
  

  show do |ad|
    attributes_table_for ad do
      row :email
      row :username
      row :city
      row :venue_name 
      row :job_title 
      row :phone 
    end
  end
end
