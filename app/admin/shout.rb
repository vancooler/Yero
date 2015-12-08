ActiveAdmin.register Shout, :as => "Shout Screening" do
  menu :parent => "SHOUT"
  permit_params :user, :user_id
  config.per_page = 100
  actions :index, :show
  batch_action :destroy, false

  controller do
    def scoped_collection
      super.includes(:user).includes(:venue) # prevents N+1 queries to your database
    end
    def remove_single_shout
      s = Shout.find_by_id(params[:id])
      shout_author_id = s.user_id
      image_url = s.image_url
      thumb_url = s.image_thumb_url
      if !s.nil?
        action_type = "Delete shout"
        details = s.body
        if s.destroy_single
          current_admin_user.add_action({'action_type' => action_type, 'details' => details, 'image_url' => image_url, 'thumb_url' => thumb_url})
          # notify author
          if Rails.env == "production"
            RecentActivity.delay.add_activity(shout_author_id, '303', nil, nil, "your-shout-deleted-"+shout_author_id.to_s+"-"+current_time.to_i.to_s, nil, nil, 'A shout you posted has been flagged as inappropriate and removed')
            WhisperNotification.delay.send_notification_shout_remove(shout_author_id, 303)
          end
          redirect_to admin_shout_screenings_path, :notice => "Shout is deleted"
        else
          redirect_to admin_shout_screenings_path, :notice => "Sorry, cannot delete this shout"
        end
        
      end
    end
  end 

  action_item :delete, only: :show do
    link_to("Delete", admin_remove_single_shout_path(shout_screening), :method => "post", :data => {:confirm => "Are you sure you want to delete this shout?"})
  end
  
  index do
    selectable_column
  	column :id
    
    column "Author (ID)", :user
    
    column "Content", :body

    column "Image", :image_url do |s|
      if s.image_thumb_url.blank? 
        '' 
      else
        link_to s.image_url, :target => "_blank" do 
          image_tag s.image_thumb_url, {:style => "height:100px;width:100px;"}
        end
      end
    end
    # column :allow_nearby
    column "Exclusive", :allow_nearby do |s|
      s.allow_nearby ? raw('<span class="status_tag no">No</span>') : raw('<span class="status_tag yes">Yes</span>')
    end
    column :created_at
    column "Network", :venue
    # column "Location", :user do |s|
    #   '[' + s.latitude.to_s + ', ' + s.longitude.to_s + ']'
    # end
    column "Actions", :actions do |s|
      link_to("View", admin_shout_screening_path(s),  :class => "member_link") + link_to("Delete", admin_remove_single_shout_path(s), :class => "member_link button small", :method => "post", :data => {:confirm => "Are you sure you want to delete this shout?"})
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

      row "Image" do 
        if shout.image_thumb_url.blank? 
          '' 
        else
          link_to shout.image_url, :target => "_blank" do 
            image_tag shout.image_thumb_url, {:style => "height:100px;width:100px;"}
          end
        end
      end
    end
  end
end
