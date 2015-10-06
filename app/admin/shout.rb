ActiveAdmin.register Shout do
  menu :parent => "SHOUT"
  permit_params :user, :user_id
  config.per_page = 100
  actions :index, :show
  batch_action :destroy, false

  controller do
    def remove_single_shout
      s = Shout.find_by_id(params[:id])
      shout_author = s.user
      if !s.nil?
        if s.destroy_single
          # notify author
          redirect_to :back, :notice => "Shout is deleted"
        else
          redirect_to :back, :notice => "Sorry, cannot delete this shout"
        end
        
      end
    end
  end 

  action_item :delete, only: :show do
    link_to("Delete", admin_remove_single_shout_path(shout), :method => "post", :data => {:confirm => "Are you sure you want to delete this shout?"})
  end
  
  index do
    selectable_column
  	column :id
    
    column "Author (ID)", :user
    
    column "Content", :body
    column :allow_nearby
    column :created_at
    column "Network", :venue
    column "Location", :user do |s|
      '[' + s.latitude.to_s + ', ' + s.longitude.to_s + ']'
    end
    column "Actions", :actions do |s|
      link_to("Delete", admin_remove_single_shout_path(s), :class => "member_link button small", :method => "post", :data => {:confirm => "Are you sure you want to delete this shout?"})
    end
    
  end
  filter :id
  filter :user
  # filter :user_id, label:      'User', as: :select, collection: User.includes(:user_avatars).where.not(user_avatars: { id: nil }).order(:id).reverse 
  # filter :user


  show do |shout|
    attributes_table_for shout do
      row :user
      row "Content" do shout.body end
    end
  end
end
