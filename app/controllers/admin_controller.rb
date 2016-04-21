class AdminController < ApplicationController

  before_filter :authenticate!
  before_filter :initialize_twitter!, only: [:twitter, :twitter_update]

  def twitter
    if request.post?
      username = params[:username].to_s
      begin
        # Api Request to get the followers for the username
        tweetFollowers = @twitter_client.followers(username)
        # Create a filter to select the name screen_name and twitter id from api response
        customFilter = Proc.new {|f| {name: f.name, screen_name: f.screen_name, twitter_id: f.id}}
        followers = tweetFollowers.map(&customFilter)
        # Check if the user already exist
        twitter_user = TwitterUser.find_by(name: username)
        if twitter_user
          twitter_user.twitter_followers.create(followers)
        else
          TwitterUser.create(name: username).twitter_followers.create(followers)
        end
        # Success message
        flash[:notice] = "Followers list added successfully!"
        redirect_to twitter_path
      rescue Twitter::Error::Unauthorized
        flash[:alert] = "Not authorized. Ask developer check the Twitter credentials in the code!"
        redirect_to :back
      rescue Twitter::Error::NotFound
        flash[:alert] = "Username '"+username+"' not found in twitter!"
        redirect_to :back
      rescue Twitter::Error::TooManyRequests => e
        flash[:notice] = "TooManyRequests. Try after #{e.rate_limit.reset_in} seconds."
        puts "TooManyRequests: "
        puts e.rate_limit.reset_in
        redirect_to :back
      rescue Exception => e
        flash[:alert] = "Something else went wrong. Please ask dev team!"
        puts "Something else went wrong!"
        puts e
        redirect_to :back
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
      raise if @twitter_followers.blank?
      respond_to do |format|
        format.json { render json: TwitterDatatable.new(view_context, @twitter_followers) }
      end
    rescue Exception => e
      redirect_to twitter_path
    end
  end

  def twitter_update
    begin
      # Get the user by id
      twitter_user = TwitterUser.find(params[:id].to_s)
      raise if twitter_user.blank?
      # Api Request to get the followers for the username
      tweetFollowers = @twitter_client.followers(twitter_user.name)
      # Create a filter to select the name screen_name and twitter id from api response
      customFilter = Proc.new {|f| {name: f.name, screen_name: f.screen_name, twitter_id: f.id}}
      followers = tweetFollowers.map(&customFilter)
      old_followers = twitter_user.twitter_followers.pluck(:twitter_id).map(&:to_i)
      new_followers = []
      followers.each do |e|
        if !old_followers.include?(e[:twitter_id])
          new_followers << e
        end
      end
      if new_followers.blank? 
        flash[:notice] = "There is no new followers found!"
      else
        twitter_user.twitter_followers.create(new_followers)
        flash[:notice] = "There is #{new_followers.count} new followers found. Updated successfully!"
      end
      redirect_to twitter_path
    rescue Twitter::Error::Unauthorized
      flash[:alert] = "Not authorized. Ask developer check the Twitter credentials in the code!"
      redirect_to twitter_path
    rescue Twitter::Error::NotFound
      flash[:alert] = "Username '"+username+"' not found in twitter!"
      redirect_to twitter_path
    rescue Twitter::Error::TooManyRequests => e
      flash[:notice] = "TooManyRequests. Try after #{e.rate_limit.reset_in} seconds."
      puts "TooManyRequests: "
      puts e.rate_limit.reset_in
      redirect_to twitter_path
    rescue Exception => e
      flash[:alert] = "Something else went wrong!"
      puts "Something else went wrong!"
      puts e
      redirect_to twitter_path
    end
  end

  private

  def authenticate!
    authenticate_or_request_with_http_basic do |username, password|
      username == "pipecandy" && password == "pipecandy1905!"
    end
  end

  def initialize_twitter!
    if Rails.env.production?
      # Credentials from PipecandyHQ twitter profile
      @twitter_client = Twitter::REST::Client.new do |config|
        config.consumer_key = "42xShxgXfxcmCafn92vnBWeOQ"
        config.consumer_secret = "1xuI5cgtl09PRX3t6mdOH8YLlrc8rchr0XwsMK0KK4fgMIof5L"
        config.access_token = "4812127693-aMMjNTgPYulpN19KGp4Hqq3hp4LJtTNiL2nw1Up"
        config.access_token_secret = "kqOjj49JVP5YhICMKS4xvVg2ocefpGMHf7B4Z4MVzfDmO"
      end
    else 
      # Credentials from thangadurai twitter profile
      @twitter_client = Twitter::REST::Client.new do |config|
        config.consumer_key = "bKkUkkna5eVuGo7XYVF3j2g0x"
        config.consumer_secret = "VAXJm2fxhPFyxSP0EAs7Uv8tfrqpYzARg9wXowMedKSw4r8ElH"
        config.access_token = "340263856-1FfyCE1UR0uC9WGAETo1nYFK6r9NJDcPtuBCuVxK"
        config.access_token_secret = "yWK6IhJKkBR22X2IBW9Rv1gsRtgqIGvcFdr5c2SoSnk4J"
      end
    end
  end
end
