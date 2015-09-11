Rails.application.routes.draw do
  require 'domain'
  require 'domain_constraint'


  constraints(Domain) do
    ActiveAdmin.routes(self)
    devise_for :admin_users, ActiveAdmin::Devise.config
  end
  
  #temporary routes for YJ to test out notification functionality
  # get 'temp_beacon/enter_random_users', as: 'enter_users'
  # get 'temp_beacon/exit_active_users', as: 'exit_active_users'

  constraints DomainConstraint.new(['www.yero.co', 'localhost', 'yero.co', 'www.example.com', 'purpleoctopus-dev.herokuapp.com', 'purpleoctopus-staging.herokuapp.com']) do
    devise_for :users
    resources :venue_portals
    resources :early_venues

    resources :beta_signup_users
    devise_for :web_users, path: '', path_names: { sign_in: 'venues/login', sign_out: 'signout', sign_up: 'signup', edit: 'settings' }
    devise_scope :web_users do
      delete "signout", :to => "devise/sessions#destroy"

      get 'dashboard', to: 'venues#dashboard', as: :venue_root
      get 'nightly', to: 'venues#nightly', as: :venue_nightly
      get 'settings', to: 'venues#settings', as: :settings

      get 'nightly/tonight', to: 'venues#tonightly', as: :venue_tonightly
      get 'nightly/:id', to: 'nightlies#show', as: :show_nightly
      get 'lottery', to: 'venues#lottery', as: :lotto
      get 'venue/pick-winner', to: 'venues#pick_winner', as: :pick_winner
      get 'lottery-dashboard', to: 'venues#lottery_dash', as: :lotto_dash
      post 'claim-drink/:winner_id', to: 'venues#claim_drink', as: :claim_drink
      get 'owner/venues', to: 'venues#index', as: :venues
      get 'owner/venues/:id', to: 'venues#show', as: :venue
      patch 'owner/venues/:id', to: 'venues#update'
      put 'owner/venues/:id', to: 'venues#update'
      get 'owner/venues/:id/edit', to: 'venues#edit', as: :edit_venue
      post 'owner/venues/approve', to: 'venues#approve', as: :venue_approve
      get 'owner/account', to: 'web_users#edit', as: :owner_account
      patch 'owner/:id', to: 'web_users#update'
      put 'owner/:id', to: 'web_users#update'
      get 'owner/:id', to: 'web_users#show', as: :web_user
      get 'owner/:id/greeting-message/:day/edit', to: 'greeting_messages#edit_message', as: :greeting_message_create
      get 'owner/:id/greeting-message/day-pick', to: 'greeting_messages#day_pick', as: :greeting_message_landing
      get 'owner/greeting-message/venues', to: 'greeting_messages#venues', as: :greeting_message_venues
      patch 'owner/greeting-message/:id', to: 'greeting_messages#update'
      put 'owner/greeting-message/:id', to: 'greeting_messages#update'
      get 'owner/greeting-message/:id', to: 'greeting_messages#show', as: :greeting_message
      post 'owner/greeting-message/approve', to: 'greeting_messages#approve', as: :greeting_message_approve
      post 'admin/disable-single-image/:id', to: 'admin/user_screenings#disable_single_image', as: :admin_disable_single_image
      post 'admin/enable-single-image/:id', to: 'admin/user_screenings#enable_single_image', as: :admin_enable_single_image
      post 'admin/disable-single-user/:id', to: 'admin/user_screenings#disable_single_user', as: :admin_disable_user_account
      post 'admin/enable-single-user/:id', to: 'admin/user_screenings#enable_single_user', as: :admin_enable_user_account
      post 'venues-csv-import', to: 'venues#import', :as => "venue_import_csv"
      post 'users-csv-import', to: 'users#import', :as => "user_import_csv"
      post 'send-test-whisper', to: 'whispers#send_test_whisper', :as => "send_test_whisper"
      put 'admin/remove-snapchat-id/:id', to: 'admin/user_screenings#remove_snapchat', as: :admin_remove_snapchat_id
      put 'admin/remove-wechat-id/:id', to: 'admin/user_screenings#remove_wechat', as: :admin_remove_wechat_id
      put 'admin/remove-line-id/:id', to: 'admin/user_screenings#remove_line', as: :admin_remove_line_id
      post 'admin/user-join/:id', to: 'admin/users#join_network', as: :admin_user_join
      post 'admin/user-leave/:id', to: 'admin/users#leave_network', as: :admin_user_leave
      post 'admin/user-send-whisper/:id', to: 'admin/users#send_whisper', as: :admin_user_send_whisper
      # Venue API
      post 'api/nightly/update_guest',     to: 'nightlies#update_guest', as: :update_guest_nightly
      post 'api/nightly/update_regular',   to: 'nightlies#update_regular', as: :update_regular_nightly
      post 'api/nightly/increase/:gender', to: 'nightlies#increase_count', as: :increase_count
    end
    # devise_scope :web_user do
    #   get "/get-in-touch" => "devise/registrations#new"
    #   get '/venue-login' => 'devise/sessions#new'
    # end



    # You can have the root of your site routed with "root"
    root 'home#index'
    # static pages below:
    get 'thanks', to: 'beta_signup_users#thanks', as: :thanks_beta_signup
    get 'faq', to: 'home#faq'
    get 'how-it-works', to: 'home#how-it-works'
    get 'contact', to: 'home#contact'
    get 'venues', to: 'home#for-venues'
    get 'privacy', to: 'home#privacy'
    get 'about', to: 'home#about'
    get 'terms', to: 'home#terms-of-use'
    get 'careers', to: 'home#careers'
    get 'venues/contact', to: 'early_venues#new', as: :get_in_touch
    get 'android', to: 'beta_signup_users#android'
    get 'beta-signup', to: 'beta_signup_users#beta'
    get 'beta-thankyou', to: 'home#beta-thankyou', as: :beta_thankyou
    get 'android-thankyou', to: 'home#android-thankyou', as: :android_thankyou
    get 'venues-thankyou', to: 'home#venues-thankyou', as: :venues_thankyou
    # get  'users/reset_password/:key',           to: 'users#reset_password', as: "reset_password"
    match 'users/password_reset/:password_reset_token',          to: 'users#password_reset', as: "password_reset", via: [:get, :post]
    match 'users/email_reset/:email_reset_token',          to: 'users#email_reset', as: "email_reset", via: [:get]
    match 'welcome',          to: 'home#welcome_reference', as: "share_reference", via: [:get]
    

  ####################################################################################################
  # 
  # Current API
  # 
  # 
    post 'api/v1/users/check-email',                  to: 'users#check_email'
    post 'api/v1/users/signup_no_avatar',       to: 'users#sign_up_without_avatar'
    post 'api/v1/users/login',                  to: 'users#login'
    delete 'api/v1/users/logout',                  to: 'users#logout'

    # users APIs
    post 'api/v1/users', to: 'users#index'
    post 'api/v1/user/show',                 to: 'users#show'
    post 'api/v1/users/generate_reset_email_verify',          to: 'users#generate_reset_email_verify'
    post 'api/v1/users/update',                 to: 'users#update_settings'
    post 'api/v1/users/update_chat_accounts',   to: 'users#update_chat_accounts'
    post 'api/v1/users/remove_chat_accounts',   to: 'users#remove_chat_accounts'
    post 'api/v1/users/forgot_password',        to: 'users#forgot_password'
    post 'api/v1/users/notification-preference', to: 'users#update_notification_preferences'
    get  'api/v1/profile',                      to: 'users#get_profile'
    put  'api/v1/user/update_profile',       to: 'users#update_profile'
    post 'api/v1/report', to: 'users#report'
    post 'api/v1/users/block-user', to: 'users#block'
    post 'api/v1/user/locations/new', to: 'locations#create'
    post 'api/v1/user/locations/show', to: 'locations#show'
    # post 'api/v1/users/like-or-unlike',                to: 'users#like'

    # avatar APIs
    post 'api/v1/avatar/create',             to: 'user_avatars#create'
    delete 'api/v1/avatar/destroy',            to: 'user_avatars#destroy'
    put  'api/v1/avatar/update',        to: 'user_avatars#update'

    # whisper APIs
    post 'api/v1/whispers', to: 'users#requests_new'
    get  'api/v1/whispers/:id', to: 'whispers#show'
    post 'api/v1/whisper/create', to: 'whispers#api_create'
    post 'api/v1/whisper/whisper_request_state', to: 'whispers#whisper_request_state'
    post 'api/v1/whisper/decline_whisper_requests', to: 'whispers#decline_whisper_requests'

    # friend APIs
    post 'api/v1/friends', to: 'users#myfriends_new'
    get  'api/v1/friends/:id', to: 'friends#show'
    
    # Activity APIs
    get  'api/v1/activities', to: 'whispers#chat_request_history'

    # Enter Venue APIs
    post 'api/v1/room/enter',   to: 'rooms#user_enter'
    post 'api/v1/room/leave',   to: 'rooms#user_leave'

    # venue APIs
    get  'api/v1/venues/list',                  to: 'venues#list'

    # Other APIs for development
    get  'api/v1/set-variable', to: 'users#set_global_variable'

  # 
  # 
  # 
  # 
  ####################################################################################################
  end



####################################################################################################
# 
# API V1
# 
# 
  api_version(:module => "V20150908", :header => {:name => "API-VERSION", :value => "V1_0"}, :defaults => {:format => :json}, :default => true) do

    post 'api/users/check-email',                  to: 'users#check_email'
    post 'api/users/signup_no_avatar',       to: 'users#sign_up_without_avatar'
    post 'api/users/login',                  to: 'users#login'
    delete 'api/users/logout',                  to: 'users#logout'

    # users APIs
    post 'api/users', to: 'users#index'
    post 'api/user/show',                 to: 'users#show'
    post 'api/users/generate_reset_email_verify',          to: 'users#generate_reset_email_verify'
    post 'api/users/update',                 to: 'users#update_settings'
    post 'api/users/update_chat_accounts',   to: 'users#update_chat_accounts'
    post 'api/users/remove_chat_accounts',   to: 'users#remove_chat_accounts'
    post 'api/users/forgot_password',        to: 'users#forgot_password'
    post 'api/users/notification-preference', to: 'users#update_notification_preferences'
    get  'api/profile',                      to: 'users#get_profile'
    put  'api/user/update_profile',       to: 'users#update_profile'
    post 'api/report', to: 'users#report'
    post 'api/users/block-user', to: 'users#block'
    post 'api/user/locations/new', to: 'locations#create'
    post 'api/user/locations/show', to: 'locations#show'
    # post 'api/users/like-or-unlike',                to: 'users#like'

    # avatar APIs
    post 'api/avatar/create',             to: 'user_avatars#create'
    delete 'api/avatar/destroy',            to: 'user_avatars#destroy'
    put  'api/avatar/update',        to: 'user_avatars#update'

    # whisper APIs
    post 'api/whispers', to: 'users#requests_new'
    get  'api/whispers/:id', to: 'whispers#show'
    post 'api/whisper/create', to: 'whispers#api_create'
    post 'api/whisper/whisper_request_state', to: 'whispers#whisper_request_state'
    post 'api/whisper/decline_whisper_requests', to: 'whispers#decline_whisper_requests'

    # friend APIs
    post 'api/friends', to: 'users#myfriends_new'
    get  'api/friends/:id', to: 'friends#show'
    
    # Activity APIs
    get  'api/activities', to: 'whispers#chat_request_history'

    # Enter Venue APIs
    post 'api/room/enter',   to: 'rooms#user_enter'
    post 'api/room/leave',   to: 'rooms#user_leave'

    # venue APIs
    get  'api/venues/list',                  to: 'venues#list'

    # Other APIs for development
    get  'api/set-variable', to: 'users#set_global_variable'
  end

# 
# 
# 
# 
####################################################################################################


####################################################################################################
# 
# API V2
# 
# 

  constraints DomainConstraint.new(['api.yero.co', 'localhost', 'devapi.yero.co', 'www.example.com']) do
    api_version(:module => "V20150930", :header => {:name => "API-VERSION", :value => "V2_0"}, :defaults => {:format => :json}) do
      # user APIs
      get     'api/users',                               to: 'users_version2#index'
      get     'api/users/:id',                           to: 'users_version2#show'
      put     'api/users',                               to: 'users_version2#update'
      get     'api/verify',                              to: 'users_version2#check_email'
      post    'api/signup',                              to: 'users_version2#signup'
      post    'api/login',                               to: 'users_version2#login'
      post    'api/emails',                              to: 'users_version2#change_email'
      post    'api/passwords',                           to: 'users_version2#forgot_password'
      put     'api/user_notification_preferences',       to: 'users_version2#update_notification_preferences'
      post    'api/report_user_histories',               to: 'users_version2#report'
      post    'api/block_users',                         to: 'users_version2#block'

      # avatar APIs
      post   'api/avatars',                              to: 'user_avatars_version2#create'
      put    'api/avatars/:id',                          to: 'user_avatars_version2#update'
      delete 'api/avatars/:id',                          to: 'user_avatars_version2#destroy'


      # venue APIs
      get    'api/venues',                               to: 'venues_version2#list'

      # Enter Venue APIs
      post   'api/venues/:id',                           to: 'rooms#user_enter'
      delete 'api/venues',                               to: 'rooms#user_leave'
      delete 'api/friends/:id',                          to: 'friends#destroy'

      # friend APIs
      get    'api/friends',                              to: 'friends#index'
      get    'api/friends/:id',                          to: 'friends#show'

      # whisper APIs
      get    'api/whispers',                             to: 'whispers#index'
      get    'api/whispers/:id',                         to: 'whispers#show'
      post   'api/whispers',                             to: 'whispers#create'
      put    'api/whispers/:id',                         to: 'whispers#update'
      delete 'api/whispers/collection',                  to: 'whispers#destroy'

      # Activity APIs
      get    'api/activities',                           to: 'activities#index'
      delete 'api/activities/:id',                       to: 'activities#destroy'

    end
  end

  
#     
# 
# 
# 
####################################################################################################


  # post 'api/v1/users/signup',                 to: 'users#sign_up'
  # post 'api/v1/users/accept_contract',        to: 'users#accept_contract'
  # post 'api/v1/users/deactivate',             to: 'users#deactivate'
  # post 'api/v1/users/connect',                to: 'users#connect'
  # post 'api/v1/users/update-apn',             to: 'users#update_apn'
  # post 'api/v1/users/network_open',           to: 'users#network_open'
  
  # get  'api/v1/nightly/get/:id',              to: 'nightlies#get', as: :get_nightly
  # post 'api/v1/venues/prospect',              to: 'venues#prospect'
  # get  'api/v1/lottery/show',                 to: 'users#get_lotto'
  # post 'api/v1/users/poke',                   to: 'users#poke'
  # get  'api/v1/users/get_pokes',              to: 'users#get_pokes'
  # get  'api/v1/users/favourite_venues',       to: 'users#favourite_venues'
  # post 'api/v1/users/add_favourite_venue',    to: 'users#add_favourite_venue'
  # post 'api/v1/users/remove_favourite_venue', to: 'users#remove_favourite_venue'
  # get 'api/v1/venues/venue_location', to: 'venues#venue_location'
  # get  'api/v1/venues/people', to: 'venues#people'
  # get  'api/v1/venues/active_users', to: 'venues#active_users'
  # post 'api/v1/avatar/create_for_signup',  to: 'user_avatars#create_avatar'
  # post 'api/v1/user/whisper_sent',         to: 'users#whisper_sent'
  # post 'api/v1/avatar/set_default',        to: 'user_avatars#set_default'
  # put 'api/v1/avatar/swap',        to: 'user_avatars#swap_photos'
  # post 'api/v1/last_activity_for',          to: 'activities#show'
  # post 'api/v1/requests', to: 'users#requests'
  # post 'api/v1/myfriends', to: 'users#myfriends'
  # get  'api/v1/whisper/create_by_url', to: 'whispers#create_by_url'
  # post 'api/v1/whisper/read', to: 'whispers#api_read'
  # post 'api/v1/notification/decline_all_chat', to: 'whispers#api_decline_all_chat'
  # post 'api/v1/notification/handle_request', to: 'whispers#chat_action'
  # post 'api/v1/whisper/chat_requests', to: 'whispers#all_my_chat_requests'
  # post 'api/v1/notification/get_info', to: 'whispers#get_info'
  # post 'api/v1/notification/delete', to: 'whispers#api_delete'
  # post 'api/v1/users/read_notification_update', to: 'users#read_notification_update'
  # Api Test Routes
  # get 'test/beacons'
  # get 'test/venues'
  # get 'test/users'
  # get 'test/'




end
