module V20150930
  class ShoutsController < ApplicationController
    prepend_before_filter :get_api_token
    before_action :authenticate_api_v2

    # show a shout
    def show
      shout = Shout.find_by_id(params[:id])
      if shout
        page = 1
        per_page = 24
        page = params[:page].to_i + 1 if !params[:page].blank?
        per_page = params[:per_page].to_i if !params[:per_page].blank?
        voted = ShoutVote.where(user_id: current_user.id).where(shout_id: shout.id)
        actions = Array.new
        if !voted.empty?
          if voted.first.upvote.nil?
            actions = ["upvote","downvote"]
          elsif voted.first.upvote
            actions = ["undo_upvote", "downvote"]
          else
            actions = ["upvote", "undo_downvote"]
          end
        else
          actions = ["upvote", "downvote"]
        end
        result = ShoutComment.list(current_user, shout.id, nil, nil)
        shout_json = {
          id:             shout.id,
          body:           shout.body,
          anonymous:      shout.anonymous,
          latitude:       shout.latitude,
          longitude:      shout.longitude,
          city:           shout.city.nil? ? '' : shout.city,
          neighbourhood:  shout.neighbourhood.nil? ? '' : shout.neighbourhood,
          timestamp:      shout.created_at.to_i,
          expire_timestamp:      shout.created_at.to_i+7*24*3600,
          total_upvotes:  shout.total_upvotes,
          actions:        actions,
          shout_comments: result['shout_comments'].length,
          shout_comments_array: result['shout_comments'],
          network_gimbal_key:       ((shout.venue.nil? or shout.venue.beacons.empty?) ? '' : shout.venue.beacons.first.key),
          author_id:      shout.user_id,
          author_username:      (User.find_by_id(shout.user_id).nil? ? "" : User.find_by_id(shout.user_id).username)
        }
        # response = {
        #   shout:          shout_json,
        #   shout_comments: result['shout_comments'],
        #   pagination:     result['pagination']
        # }
        render json: success(shout_json)
      else
        # :nocov:
        error_obj = {
          code: 404,
          message: "Cannot find the shout."
        }
        render json: error(error_obj, 'error')
        # :nocov:
      end
    end


    # create a shout
    def create
      venue = (params[:venue].blank? ? nil : params[:venue])
      city = (params[:city].blank? ? '' : params[:city])
      neighbourhood = (params[:neighbourhood].blank? ? '' : params[:neighbourhood])
      anonymous = (!params['anonymous'].nil? ? (params['anonymous'].to_s == '1' or params['anonymous'].to_s == 'true') : true)
      
      shout = Shout.create_shout(current_user, params[:body], venue, anonymous, city, neighbourhood)
      if shout
        # Pusher later
        render json: success(shout)
      else
        # :nocov:
        error_obj = {
          code: 520,
          message: "Cannot create the shout."
        }
        render json: error(error_obj, 'error')
        # :nocov:
      end
    end

    # retrieve shouts with venue filter and order
    def index
      page = nil
      per_page = nil
      page = params[:page].to_i + 1 if !params[:page].blank?
      per_page = params[:per_page].to_i if !params[:per_page].blank?

      result = Shout.list(current_user, params[:order_by], params[:venue], params[:my_shouts], params[:my_comments], page, per_page)
      response = {
        shouts: result['shouts']
      }
      render json: success(response, "data", result['pagination'])
    end

    # upvote or downvote
    def update
      shout = Shout.find_by_id(params[:id])
      result = shout.change_vote(current_user, params[:upvote])

      if result[:result]
        # Pusher later
        render json: success
      else
        # :nocov:
        error_obj = {
          code: 520,
          message: "Cannot update the shout."
        }
        render json: error(error_obj, 'error')
        # :nocov:
      end
    end

    # delete a shout
    def destroy
      shout = Shout.find_by_id(params[:id])
      if shout.user_id == current_user.id
        if shout.destroy_single
          render json: success
        else
          # :nocov:
          error_obj = {
            code: 520,
            message: "Cannot delete this shout"
          }
          render json: error(error_obj, 'error')
          # :nocov:
        end
      else
        error_obj = {
          code: 403,
          message: "You are not the author of this shout"
        }
        render json: error(error_obj, 'error')
      end
    end

    # report a shout
    def report
      shout = Shout.find_by_id(params[:shout_id])
      report_type = ShoutReportType.find_by_id(params[:report_type_id])
      if shout and report_type
        shout.report(current_user, report_type.id)
        render json: success
      else
        # :nocov:
        error_obj = {
          code: 520,
          message: "Cannot report the shout."
        }
        render json: error(error_obj, 'error')
        # :nocov:
      end
    end





    private

    def get_api_token
      if (Rails.env != 'test' && api_token = params[:token].blank? && request.headers["X-API-TOKEN"])
        # :nocov:
        params[:token] = api_token 
        # :nocov:
      end
    end
  end
end