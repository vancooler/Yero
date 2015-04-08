ActiveAdmin.register UserAvatar do
  menu :parent => "USERS"
  actions :index, :show
  batch_action :destroy, false
  batch_action :disable, :confirm => "Are you sure you want to disable all of these avatars?" do |selection|
    UserAvatar.find(selection).each do |ua|
      ua.is_active = false
      ua.save!
    end
    redirect_to :back, :notice => "Selected avatars are disabled"
  end
  batch_action :enable, :confirm => "Are you sure you want to enable all of these avatars?" do |selection|
    UserAvatar.find(selection).each do |ua|
      ua.is_active = true
      ua.save!
    end
    redirect_to :back, :notice => "Selected avatars are enabled"
  end
  index do
    selectable_column
  	column :id
    column :user
    column "Is default", :default
    column :is_active
    actions
  end
  filter :id
  filter :user
  filter :default
  filter :is_active

  # form do |f|
  #   f.inputs "Details" do
  #     f.input :user
  #     f.input :avatar
  #     f.input :default
      
  #   end
  #   f.actions
  # end

  show do |user|
    attributes_table_for user do
      row :user
      row :avatar do
          image_tag(user.avatar)
      end
      row :default
    end
  end
end
