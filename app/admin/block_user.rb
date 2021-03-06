ActiveAdmin.register BlockUser do
  menu :parent => "REPORT", :if => proc { !current_admin_user.level.nil? and current_admin_user.level == 0 }
  before_filter :check_super

  controller do
    def check_super
      redirect_to admin_root_path, :notice => "You do not have access to this page" unless !current_admin_user.level.nil? and current_admin_user.level == 0
    end
  end
  actions :index, :destroy
  # config.sort_order = 'frequency_desc'
  # def scoped_collection
  #   super.includes :reported_user, :reporting_user # prevents N+1 queries to your database
  # end

  # controller do
  #   def scoped_collection
  #     array = ReportUserHistory.all.select("id, reported_user_id, report_type_id, updated_at").group_by { |x| [x.reported_user_id, x.report_type_id] }.map {|x,y|y.max_by {|x| x['updated_at']}}
  #     id_array = Array.new
  #     array.each do |a|
  #       id_array << a.id
  #     end
  #     ReportUserHistory.where(:id => id_array)
  #   end
  # end 

  index do
  	column :id
    # column :reporting_user
    column "User A", :origin_user
    column "User B", :target_user
  	actions
  end

  filter :origin_user

end
