ActiveAdmin.register ShareHistory do
  menu :parent => "Share", :if => proc { !current_admin_user.level.nil? and current_admin_user.level == 0 }
  before_filter :check_super

  controller do
    def check_super
      redirect_to admin_root_path, :notice => "You do not have access to this page" unless !current_admin_user.level.nil? and current_admin_user.level == 0
    end
  end
  
  actions :index, :show

  def scoped_collection
    super.includes :share_reference # prevents N+1 queries to your database
  end

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
    column :share_reference, sortable: "share_reference_id"
    column :created_at
  	actions
  end


  filter :share_reference

  show do |history|
    attributes_table_for history do
      row :share_reference
      row :created_at
    end
  end
end
