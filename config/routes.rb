Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  devise_for :venues, path: '', path_names: { sign_in: 'signin', sign_out: 'signout', sign_up: 'signup', edit: 'settings' }

  devise_scope :venues do
    get 'dashboard', to: 'venues#dashboard', as: :venue_root
    get 'nightly', to: 'venues#nightly', as: :venue_nightly
    # get 'settings', to: 'venues#settings', as: :venue_settings

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
  post 'api/v1/users/avatar/add',             to: 'users#add_avatar'
  post 'api/v1/users/avatar/remove_avatar',   to: 'users#remove_avatar'
  post 'api/v1/users/avatar/update_image',    to: 'users#update_image'
  post 'api/v1/users/avatar/make_default',    to: 'users#make_default'
  get  'api/v1/last_activity/:key',           to: 'activities#show'
  # Venue/Beacon API
  post 'api/v1/room/enter',   to: 'rooms#user_enter'
  post 'api/v1/room/leave',   to: 'rooms#user_leave'
  get  'api/v1/venues/people', to: 'venues#people'

  # Api Test Routes
  # get 'test/beacons'
  # get 'test/venues'
  # get 'test/users'
  # get 'test/'
end
