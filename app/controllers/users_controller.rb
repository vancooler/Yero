class UsersController < ApplicationController
  before_action :authenticate_api, except: [:sign_up]
  skip_before_filter  :verify_authenticity_token

  # API

  def sign_up
    user = User.new(sign_up_params)

    if user.valid?
      user.save!
      # user.create_layer_account
      # user.user_avatars.first.update_attribute(:default, true)
      # TODO refactor avatars to a separate class
      # TODO bring back this code after the chat is working. 
      render json: success(user.to_json(true))
    else
      render json: error(JSON.parse(user.errors.messages.to_json))
    end
  end

  def update_settings
    user = User.find_by_key(params[:key])
    user.assign_attributes(sign_up_params)

    if user.valid?
      user.save!
      render json: success(user.to_json(false))
    else
      render json: error(JSON.parse(user.errors.messages.to_json))
    end
  end

  # Make a new default avatar
  # TODO Rename this crap
  def make_default
    user = User.find_by_key(params[:key])
    avatar = user.user_avatars.find(params[:avatar_id])
    old_default = user.user_avatars.where(default: true).first

    if avatar && avatar != old_default
      user.user_avatars.where(default: true).first.update_attribute(:default, false)
      avatar.update_attribute(:default, true)

      render json: success(user.to_json(false))
    else
      render json: error("Avatar does not exist or image is already default")
    end
  end

  def add_avatar
    user = User.find_by_key(params[:key])
    avatar = UserAvatar.new
    avatar.user = user
    avatar.avatar = params[:avatar]

    if avatar.save
      render json: success(user.to_json(false))
    else
      render json: error("Invalid image")
    end
  end

  def update_image
    user = User.find_by_key(params[:key])
    avatar = user.user_avatars.find(params[:avatar_id])

    if avatar && avatar.update_image(params[:avatar])
      render json: success(user.to_json(false))
    else
      render json: error("Invalid image")
    end
  end

  def remove_avatar
    user = User.find_by_key(params[:key])

    if user.user_avatars.all.size == 1
      render json: error("Cannot remove image, user must have at least 1 image")
    else
      avatar = user.user_avatars.find(params[:avatar_id])
      if avatar && avatar.destroy
        user.user_avatars.first.update_attribute(:default, true)
        render json: success(user.to_json(false))
      else
        render json: error("Avatar does not exist")
      end
    end
  end

  def update_apn
    user = User.find_by_key(params[:key])
    user.apn_token = params[:token]
    user.save

    render json: success(user.to_json(false))
  end

  def get_profile
    user = User.find_by_key(params[:key])
    render json: success(user.to_json(false))
  end

  def get_lotto
    winnings = User.find_by_key(params[:key]).winners.all

    data = Jbuilder.encode do |json|
      json.winnings winnings, :message, :created_at, :winner_id, :claimed
    end

    render json: success(JSON.parse(data))
  end

  def poke
    pokee = User.find(params[:user_id])

    if pokee
      p = Poke.where(pokee: pokee, poker: current_user).first

      unless p
        p = Poke.new
        p.poker = current_user
        p.pokee = pokee
        p.save
      end

      render json: success(nil)
    else
      render json: error("User does no exist")
    end
  end

  def add_favourite_venue
    user = User.find_by_key(params[:key])
    venue = Venue.find(params[:venue_id])
    if user && venue && !user.favourite_venues.where(venue: venue).first
      fav = FavouriteVenue.new
      fav.user = user
      fav.venue = venue
      fav.save

      render json: success(nil)
    else
      render json: error("Error, user/venue does exist or venue is already a favourite of the user")
    end
  end

  def remove_favourite_venue
    user = User.find_by_key(params[:key])
    venue = Venue.find(params[:venue_id])

    if user && venue
      fav = user.favourite_venues.where(venue: venue).first
      if fav
        fav.destroy

        render json: success(nil)
      end
    else
      render json: error("Error, user/venue does not exist or venue is not a favourite of the user")
    end
  end

  # A list of the user's favourite venues
  # TODO refactor out the JSON data builder to venue.rb
  def favourite_venues
    user = User.find_by_key(params[:key])

    favourites = user.favourite_venues

    data = Jbuilder.encode do |json|
      images = ["https://s3.amazonaws.com/whisprdev/test_nightclub/n1.jpg", "https://s3.amazonaws.com/whisprdev/test_nightclub/n2.jpg", "https://s3.amazonaws.com/whisprdev/test_nightclub/n3.jpg"]

      json.array! favourites do |f|

        v = f.venue

        json.id v.id
        json.name v.name
        json.address v.address_line_one
        json.city v.city
        json.state v.state
        json.longitude v.longitude
        json.latitude v.latitude
        json.is_favourite FavouriteVenue.where(venue: v, user: User.find_by_key(params[:key])).exists?
        json.images do
          json.array! images
        end

        json.nightly do
          nightly = Nightly.today_or_create(v)
          json.boy_count nightly.boy_count
          json.girl_count nightly.girl_count
          json.guest_wait_time nightly.guest_wait_time
          json.regular_wait_time nightly.regular_wait_time
        end
      end
    end

    render json: {
      list: JSON.parse(data)
    }
  end

  # Get all the chat requests sent to the user
  # TODO refactor out the JSON builder into poke.rb
  def get_pokes
    user = User.find_by_key(params[:key])

    pokes = Poke.where(pokee: user).all

    data = Jbuilder.encode do |json|
      json.array! pokes do |p|

        json.id = p.id

        json.poker do
          poker = p.poker

          json.id poker.id
          json.first_name poker.first_name
          json.avatar poker.default_avatar.avatar.thumb.url
        end

        json.timestamp p.poked_at
      end
    end

    render json: {
      list: JSON.parse(data)
    }
  end

  private

  def sign_up_params
    params.require(:user).permit(:email, :birthday, :first_name, :gender, user_avatars_attributes: [:avatar])
  end
end