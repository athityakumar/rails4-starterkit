class AdminController < ApplicationController

  before_filter :authenticate!

  def twitter
    if request.post?
      begin
        username = params[:username].to_s
        twitter_user = TwitterUser.find_by_name(username)
        if twitter_user.blank?
          twitter_user = TwitterUser.create(name: username, is_processing: true)
          # perform add followers_list to the follower table
          job = FetchCreateFollowerJob.perform_later(twitter_user)
          puts "======>Jobs for #{username}: #{job.to_s}<======"
          flash[:notice] = "&#x263A;&nbsp;&nbsp;User Added Successfully"
        else
          flash[:notice] = "User is already added. Click update in the below table!"
        end
        redirect_to twitter_path
      rescue Exception => e
        flash[:alert] = "&#x1f61e;&nbsp;&nbsp;Error when saving the user"
        redirect_to twitter_path
      end
    else
      @twitter_users = TwitterUser.all
      @twitter_followers = TwitterFollower.all
      respond_to do |format|
        format.html
        format.json { render json: TwitterDatatable.new(view_context, @twitter_followers) }
      end
    end
  end

  def twitter_followers
    begin
      raise unless request.format == "json"
      @twitter_user = TwitterUser.find(params[:id].to_s)
      raise if @twitter_user.blank?
      @twitter_followers = @twitter_user.twitter_followers
      respond_to do |format|
        format.json { render json: TwitterDatatable.new(view_context, @twitter_followers) }
      end
    rescue Exception => e
      redirect_to twitter_path
    end
  end

  def twitter_job_rerun
    begin
      twitter_user = TwitterUser.find(params[:id].to_s)
      raise if twitter_user.blank?
      if twitter_user.is_processing
        flash[:notice] = "This user job is already running. So keep wait!"
      else
        flash[:notice] = "&#x263A;&nbsp;&nbsp;Rerunning to update this user list. Verify sidekiq!"
        twitter_user.update(is_processing: true)
        job = FetchCreateFollowerJob.perform_later(twitter_user)
        puts "======>Jobs for #{twitter_user.name.to_s}: #{job.to_s}<======"
      end
      redirect_to twitter_path
    rescue Exception => e
      flash[:alert] = "&#x1f61e;&nbsp;&nbsp;User not exist!"
      redirect_to twitter_path
    end
  end

  def inbound
    if request.post?
      input_url = params[:inbound_search_query_link].to_s
      if input_url.blank?
        flash[:alert] = "Input link seems invalid"
      else
        job = FetchCreateInboundJob.perform_later(input_url)
        flash[:notice] = "You inbound link is added!. Please wait!."
      end
      redirect_to inbound_path
    else
      @inbound_users = InboundUser.all
      respond_to do |format|
        format.html
        format.json { render json: InboundDatatable.new(view_context, @inbound_users) }
      end
    end
  end

  def ajax_inbound_user_modal
    @inbound_user = InboundUser.find(params[:id].to_s)
    respond_to do |format|
      format.js {render "inbound"}
    end
  end

  private

  def authenticate!
    authenticate_or_request_with_http_basic do |username, password|
      username == "pipecandy" && password == "pipecandy1905!"
    end
  end
end
