ActiveAdmin.register AdminAction do
    menu :parent => "SuperAdmin", :if => proc { !current_admin_user.level.nil? and current_admin_user.level == 0 }

    before_filter :check_super
    config.per_page = 100
    actions :index

    controller do
      def check_super
        redirect_to admin_root_path, :notice => "You do not have access to this page" unless !current_admin_user.level.nil? and current_admin_user.level == 0
      end
    end

    index do
      id_column
      column :admin_user
      column :action_type
      column "Details", :details do |action|
        raw(action.details)
      end
      column "Image", :image_url do |action|
        if !action.image_url.blank?
          link = link_to action.image_url, :target => "_blank" do 
            image_tag action.thumb_url, {:style => "height:100px;width:100px;"}
          end
        else
          link = ''
        end
        link
      end
      actions
    end

    filter :admin_user
end
