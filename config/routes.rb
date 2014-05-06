Rails.application.routes.draw do
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
    post 'api/nightly/update_guest', to: 'nightlies#update_guest', as: :update_guest_nightly
    post 'api/nightly/update_regular', to: 'nightlies#update_regular', as: :update_regular_nightly
    post 'api/nightly/increase/:gender', to: 'nightlies#increase_count', as: :increase_count
  end

  # You can have the root of your site routed with "root"
  root 'home#index'

  # User API
  get 'api/nightly/get/:id', to: 'nightlies#get', as: :get_nightly
  get 'api/venues/list', to: 'venues#list', as: :venue_list
  get 'api/profile', to: 'users#get_profile'
  post 'api/users/signup', to: 'users#sign_up'
  post 'api/users/update', to: 'users#update_settings'
  post 'api/users/update-apn', to: 'users#update_apn'
  get 'api/lottery/show', to: 'users#get_lotto'

  # Venue/Beacon API
  post 'api/room/enter', to: 'rooms#user_enter'
  post 'api/room/leave', to: 'rooms#user_leave'
end
