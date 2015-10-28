ActiveAdmin.register GreetingMessage do
  menu :parent => "VENUE", :if => proc { !current_admin_user.level.nil? and current_admin_user.level == 0 }
  before_filter :check_super

  controller do
    def check_super
      redirect_to admin_root_path, :notice => "You do not have access to this page" unless !current_admin_user.level.nil? and current_admin_user.level == 0
    end
  end
  permit_params :venue_id, :weekday_id, :draft_pending, 
                :admission_fee, :drink_special, :description, :first_dj, :second_dj, :last_call,
                :pending_admission_fee, :pending_drink_special, :pending_description, 
                :pending_first_dj, :pending_second_dj, :pending_last_call,
                greeting_posters_attributes: [:id, :avatar, :greeting_message_id, :default, :_destroy]
  before_filter :check_super, only: [:edit, :update, :create, :new, :destroy]
  # actions :index, :show, :if => proc { !current_admin_user.level.nil? and current_admin_user.level == 0 }
  controller do
    def check_super
      puts current_admin_user.level
      redirect_to admin_root_path, :notice => "You do not have access to this page" unless !current_admin_user.level.nil? and current_admin_user.level == 0
    end
  end

  action_item :only => :show, :if => proc { !current_admin_user.level.nil? and current_admin_user.level == 0 } do
    if !greeting_message.draft_pending.nil? and greeting_message.draft_pending
      link_to('Approve pending draft', greeting_message_approve_url(:greeting_message => greeting_message), :method => "post", :data => {:confirm => 'Are you sure?'}) 
    end
  end

  # batch_action :do_something do |selection|
  #   Venue.find(selection).each do |venue|
  #     # venue.status = 0
  #     # venue.save!
  #   end
  #   redirect_to :back
  # end
  # batch_action :destroy, false

  scope :pending
  index do
    # selectable_column
  	column :id
    # column :email
    column "Type", :venue
    column "Day", :weekday
    column :first_dj
    column :second_dj
    column :last_call
    column :last_call_as
    column :admission_fee
    column :drink_special
    column :description
    
    column :draft_pending
  	actions


    # venues.each do |v|
    #   v.pending_name = v.name
    #   v.pending_email = v.email
    #   v.pending_phone = v.phone
    #   v.pending_address = v.address_line_one
    #   v.pending_city = v.city
    #   v.pending_state = v.state
    #   v.pending_zipcode = v.zipcode
    #   v.pending_country = v.country
    #   v.pending_manager_first_name = v.manager_first_name
    #   v.pending_manager_last_name = v.manager_last_name
    #   v.pending_venue_type_id = v,venue_type_id
    # end

  end
  filter :venue
  filter :weekday
  filter :draft_pending

  form do |f|
    f.inputs "Details" do
      f.input :venue
      f.input :weekday, :label => "Day"
      f.input :draft_pending
      f.input :first_dj
      f.input :second_dj
      f.input :last_call
      f.input :last_call_as
      f.input :admission_fee
      f.input :drink_special
      f.input :description
      f.input :pending_first_dj
      f.input :pending_second_dj
      f.input :pending_last_call
      f.input :pending_last_call_as
      f.input :pending_admission_fee
      f.input :pending_drink_special
      f.input :pending_description
      
    end
    

    f.inputs do
      f.has_many :greeting_posters, heading: 'Pictures', allow_destroy: true, new_record: true do |b|
        b.input :avatar, :image_preview => true
        b.input :default, :label => "Approved"
      end
    end
    f.actions
  end

  show do |venue|
    div :class => "table" do 
      table do
        tr do
          th "Attributes"
          th "Live Info"
          th "Pending Info" if venue.draft_pending
        end
        tr do
          td "First DJ"
          td venue.first_dj
          td venue.pending_first_dj
        end
        
        tr do
          td "Second DJ"
          td venue.second_dj
          td venue.pending_second_dj
        end
        tr do
          td "Last Call"
          td venue.last_call
          td venue.pending_last_call
        end
        tr do
          td "Last Call As"
          td venue.last_call_as
          td venue.pending_last_call_as
        end
        tr do
          td "Admission Fee"
          td venue.admission_fee
          td venue.pending_admission_fee
        end
        tr do
          td "Drink Special"
          td venue.drink_special
          td venue.pending_drink_special
        end
        
        tr do
          td "Description"
          td venue.description
          td venue.pending_description
        end

        tr do
          td "Poster"
          td !venue.greeting_posters.where(:default => true).first.nil? ? image_tag(venue.greeting_posters.where(:default => true).first.avatar, :style => "height:345px;width:217px;") : ''
          td !venue.greeting_posters.where(:default => false).first.nil? ? image_tag(venue.greeting_posters.where(:default => false).first.avatar, :style => "height:345px;width:217px;") : ''
        end
        
      end
    end

    
  end
end
