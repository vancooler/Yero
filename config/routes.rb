Rails.application.routes.draw do

  devise_for :web_users, path: '', path_names: { sign_in: 'signin', sign_out: 'signout', sign_up: 'signup', edit: 'settings' }
  #temporary routes for YJ to test out notification functionality
  get 'temp_beacon/enter_random_users', as: 'enter_users'
  get 'temp_beacon/exit_active_users', as: 'exit_active_users'

  devise_scope :web_users do
    get 'dashboard', to: 'venues#dashboard', as: :venue_root
    get 'nightly', to: 'venues#nightly', as: :venue_nightly
    get 'settings', to: 'venues#settings', as: :settings

    get 'nightly/tonight', to: 'venues#tonightly', as: :venue_tonightly
    get 'nightly/:id', to: 'nightlies#show', as: :show_nightly
    get 'lottery', to: 'venues#lottery', as: :lotto
    get 'venue/pick-winner', to: 'venues#pick_winner', as: :pick_winner
    get 'lottery-dashboard', to: 'venues#lottery_dash', as: :lotto_dash
    post 'claim-drink/:winner_id', to: 'venues#claim_drink', as: :claim_drink

    # Venue API
    post 'api/nightly/update_guest',     to: 'nightlies#update_guest', as: :update_guest_nightly
    post 'api/nightly/update_regular',   to: 'nightlies#update_regular', as: :update_regular_nightly
    post 'api/nightly/increase/:gender', to: 'nightlies#increase_count', as: :increase_count
  end

  # You can have the root of your site routed with "root"
  root 'home#index'
  # static pages below:
  get 'faq', to: 'home#faq'
  get 'how-it-works', to: 'home#how-it-works'
  get 'contact', to: 'home#contact'
  get 'for-venues', to: 'home#for-venues'
  get 'privacy', to: 'home#privacy'
  get 'about', to: 'home#about'
  get 'terms-of-use', to: 'home#terms-of-use'
  get 'careers', to: 'home#careers'
  get 'android', to: 'home#android'
  get 'beta-signup', to: 'home#beta'
  # User API
  post 'api/v1/users/signup',                 to: 'users#sign_up'
  post 'api/v1/users/update',                 to: 'users#update_settings'
  post 'api/v1/users/update-apn',             to: 'users#update_apn'
  get  'api/v1/nightly/get/:id',              to: 'nightlies#get', as: :get_nightly
  get  'api/v1/venues/list',                  to: 'venues#list',       as: :venue_list
  get  'api/v1/profile',                      to: 'users#get_profile'
  get  'api/v1/lottery/show',                 to: 'users#get_lotto'
  post 'api/v1/users/poke',                   to: 'users#poke'
  get  'api/v1/users/get_pokes',              to: 'users#get_pokes'
  get  'api/v1/users/favourite_venues',       to: 'users#favourite_venues'
  post 'api/v1/users/add_favourite_venue',    to: 'users#add_favourite_venue'
  post 'api/v1/users/remove_favourite_venue', to: 'users#remove_favourite_venue'
  get  'api/v1/venues/people', to: 'venues#people'
  get  'api/v1/venues/active_users', to: 'venues#active_users'

  post 'api/v1/avatar/create',             to: 'user_avatars#create'
  post 'api/v1/avatar/create_for_signup',  to: 'user_avatars#create_avatar'
  post 'api/v1/avatar/destroy',            to: 'user_avatars#destroy'
  post 'api/v1/avatar/set_default',        to: 'user_avatars#set_default'
  post 'api/v1/user/update_profile',       to: 'users#update_profile'
  post 'api/v1/user/show',                 to: 'users#show'

  post 'api/v1/last_activity_for',          to: 'activities#show'
  post 'api/v1/users', to: 'users#index'
  post 'api/v1/friends', to: 'users#friends'
  post 'api/v1/user/locations/new', to: 'locations#create'
  post 'api/v1/user/locations/show', to: 'locations#show'
  resources :whispers, only: [:new, :create]
  get  'api/v1/whisper/create_by_url', to: 'whispers#create_by_url'
  post 'api/v1/whisper/create', to: 'whispers#api_create'
  post 'api/v1/whisper/read', to: 'whispers#api_read'
  post 'api/v1/notification/handle_request', to: 'whispers#chat_action'
  post 'api/v1/whisper/chat_requests', to: 'whispers#all_my_chat_requests'
  post 'api/v1/notification/get_info', to: 'whispers#get_info'
  post 'api/v1/whisper/chat_request_history', to: 'whispers#chat_request_history'
  post 'api/v1/notification/delete', to: 'whispers#api_delete'
  post 'api/v1/notification/decline_all_chat', to: 'whispers#api_decline_all_chat'

  # Venue/Beacon API
  post 'api/v1/room/enter',   to: 'rooms#user_enter'
  post 'api/v1/room/leave',   to: 'rooms#user_leave'
  # post 'api/v1/users/read_notification_update', to: 'users#read_notification_update'
  # Api Test Routes
  # get 'test/beacons'
  # get 'test/venues'
  # get 'test/users'
  # get 'test/'
end
