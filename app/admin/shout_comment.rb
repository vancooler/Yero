ActiveAdmin.register ShoutComment do
  menu :parent => "SHOUT"
  permit_params :user, :user_id
  config.per_page = 100
  actions :index, :show
  batch_action :destroy, false

  controller do
    def remove_single_shout_comment
      sc = ShoutComment.find_by_id(params[:id])
      shout_comment_author_id = sc.user_id
      image_url = sc.image_url
      thumb_url = sc.image_thumb_url
      if !sc.nil?
        action_type = "Delete shout reply"
        details = sc.body
        if sc.destroy_single
          current_admin_user.add_action({'action_type' => action_type, 'details' => details, 'image_url' => image_url, 'thumb_url' => thumb_url})
          # notify author
          if Rails.env == "production"
            RecentActivity.delay.add_activity(shout_comment_author_id, '304', nil, nil, "your-shout-comment-deleted-"+shout_comment_author_id.to_s+"-"+current_time.to_i.to_s, nil, nil, 'A reply you posted has been flagged as inappropriate and removed')
            WhisperNotification.delay.send_notification_shout_remove(shout_comment_author_id, 304)
          end
          redirect_to :back, :notice => "Comment is deleted"
        else
          redirect_to :back, :notice => "Sorry, cannot delete this shout comment"
        end
      end
    end
  end 

  action_item :delete, only: :show do
    link_to("Delete", admin_remove_single_shout_comment_path(shout_comment), :method => "post", :data => {:confirm => "Are you sure you want to delete this comment?"})
  end
  
  index do
    selectable_column
  	column :id
    
    column "Author (ID)", :user
    
    column "Content", :body
    column "Image", :image_url do |s|
      if s.image_thumb_url.nil? 
        '' 
      else
        link_to s.image_url, :target => "_blank" do 
          image_tag s.image_thumb_url, {:style => "height:100px;width:100px;"}
        end
      end
    end
    column :shout_id
    column :created_at
    column "Location", :user do |s|
      '[' + s.latitude.to_s + ', ' + s.longitude.to_s + ']'
    end
    column "Actions", :actions do |s|
      link_to("View", admin_shout_path(s),  :class => "member_link") + link_to("Delete", admin_remove_single_shout_comment_path(s), :class => "member_link button small", :method => "post", :data => {:confirm => "Are you sure you want to delete this comment?"})
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
        if shout.image_thumb_url.nil? 
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
