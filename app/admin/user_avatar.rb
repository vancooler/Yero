ActiveAdmin.register UserAvatar do
  menu :parent => "USERS"
  actions :index, :show, :destroy
  index do
  	column :id
    column :user
    column "Is default", :default
    actions
  end
  filter :id
  filter :user
  filter :default

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
