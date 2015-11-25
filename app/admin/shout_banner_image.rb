ActiveAdmin.register ShoutBannerImage do
  menu :parent => "SHOUT", :if => proc { !current_admin_user.level.nil? and current_admin_user.level == 0 }
  before_filter :check_super

  controller do
    def check_super
      redirect_to admin_root_path, :notice => "You do not have access to this page" unless !current_admin_user.level.nil? and current_admin_user.level == 0
    end
  end
  
  permit_params :is_active, :avatar
  
  before_filter :check_super, only: [:edit, :update, :create, :new, :destroy]
  # actions :index, :show, if: proc { !current_admin_user.level.nil? and current_admin_user.level == 0 }
  controller do
    def check_super
      puts current_admin_user.level
      redirect_to admin_root_path, :notice => "You do not have access to this page" unless !current_admin_user.level.nil? and current_admin_user.level == 0
    end
  end

  index do
  	column :id
    column "Image", :avatar do |avatar|
      image_tag avatar.avatar.url
    end
    # column "Enabled", :is_active
  	actions
  end
  filter :is_active

  form do |f|
    f.inputs "Details" do
      f.input :avatar, :label => "Image", :image_preview => true
      # f.input :is_active
      
    end
    f.actions
  end

  show do |shout_banner_image|
    attributes_table_for shout_banner_image do
      row 'Image' do
          image_tag shout_banner_image.avatar
      end
      # row :is_active
    end
  end
end
