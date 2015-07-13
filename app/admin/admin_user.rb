ActiveAdmin.register AdminUser do
    menu :parent => "SuperAdmin", :if => proc { !current_admin_user.level.nil? and current_admin_user.level == 0 }

    permit_params :email, :password, :password_confirmation

    before_filter :check_super

    controller do
      def check_super
        puts "DEBUG"
        # puts self
        puts current_admin_user.level
        redirect_to admin_root_path, :notice => "You do not have access to this page" unless !current_admin_user.level.nil? and current_admin_user.level == 0
      end
    end

    index do
      selectable_column
      id_column
      column :email
      # column :current_sign_in_at
      # column :sign_in_count
      # column :created_at
      column :level
      actions
    end

    filter :email
    filter :level
    # filter :current_sign_in_at
    # filter :sign_in_count
    # filter :created_at

    form do |f|
      f.inputs "Admin Details" do
        f.input :email
        f.input :password
        f.input :password_confirmation
        f.input :level
      end
      f.actions
    end

end
