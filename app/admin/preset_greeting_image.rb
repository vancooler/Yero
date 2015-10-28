ActiveAdmin.register PresetGreetingImage do
  menu :parent => "VENUE", :if => proc { !current_admin_user.level.nil? and current_admin_user.level == 0 }
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
      image_tag avatar.avatar.url, {:style => "height:345px;width:217px;"}
    end
    column "Enabled", :is_active
  	actions
  end
  filter :is_active

  form do |f|
    f.inputs "Details" do
      f.input :avatar, :label => "Image", :image_preview => true, :style => "height:345px;width:217px;"
      f.input :is_active
      
    end
    f.actions
  end

  show do |venue|
    attributes_table_for venue do
      row 'Image' do
          image_tag venue.avatar, {:style => "height:345px;width:217px;"}
      end
      row :is_active
    end
  end
end
