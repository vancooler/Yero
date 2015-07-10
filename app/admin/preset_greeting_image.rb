ActiveAdmin.register PresetGreetingImage do
  menu :parent => "VENUE"
  permit_params :is_active, :avatar
  
  index do
  	column :id
    column :avatar do |avatar|
      image_tag avatar.avatar.url, {:style => "height:345px;width:217px;"}
    end
    column "Is Active", :is_active
  	actions
  end
  filter :is_active

  form do |f|
    f.inputs "Details" do
      f.input :avatar, :image_preview => true, :style => "height:345px;width:217px;"
      f.input :is_active
      
    end
    f.actions
  end

  show do |venue|
    attributes_table_for venue do
      row :avatar do
          image_tag venue.avatar, {:style => "height:345px;width:217px;"}
      end
      row :is_active
    end
  end
end
