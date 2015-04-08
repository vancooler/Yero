ActiveAdmin.register UserAvatar do
  menu :parent => "USERS"
  permit_params :user, :default, :avatar, :user_id, :is_active

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
    column "User (ID)", :user
    column "Is default", :default
    column :is_active
    actions
  end
  filter :id
  # filter :user
  filter :user, as: :select, collection: UserAvatar.includes(:user).order(:user_id).collect { |cat| [cat.user.name, cat.user.id] if !cat.user.nil? }
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
