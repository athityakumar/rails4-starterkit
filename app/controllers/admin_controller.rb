class AdminController < ApplicationController

  before_filter :authenticate!

  def index
    all_concierge = Concierge.all
    @concierge = all_concierge.order(created_at: :desc).paginate(page: params[:page], per_page: 20)
    respond_to do |format|
      format.html
      format.csv { send_data all_concierge.to_csv }
      format.xls { send_data all_concierge.to_csv(col_sep: "\t") }
    end
  end

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
      @twitter_tweets_all = TwitterTweet.all
      @twitter_users = TwitterUser.all
      @twitter_followers = TwitterFollower.all
      respond_to do |format|
        format.html
        format.json { render json: TwitterDatatable.new(view_context, @twitter_followers) }
      end
    end
  end

  def twitter_tweets_all
    @twitter_tweets_all = TwitterTweet.all
    respond_to do |format|
      format.json { render json: TwitterTweetsAllDatatable.new(view_context, @twitter_tweets_all) }
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

  def twitter_tweets
    @twitter_follower = TwitterFollower.find(params[:id].to_s)
    @twitter_name = @twitter_follower.name  
    @tweets_by_user = TwitterTweet.where("user_id = ?",@twitter_follower.twitter_id) 
    unless @tweets_by_user.count == 0
      respond_to do |format|
        format.html
        format.json { render json: TwitterTweetsDatatable.new(view_context, @tweets_by_user) }    
      end
    end
    
  end

  def inbound
    if request.post?
      input_url = params[:inbound_search_query_link].to_s
      unless input_url.blank?
        InboundLink.create(link: input_url)
        flash[:notice] = "You inbound link is added!. Click the run button!"
      end
      redirect_to inbound_path
    else
      @inbound_links = InboundLink.all
      @inbound_users = InboundUser.all
      respond_to do |format|
        format.html
        format.csv { send_data @inbound_users.to_csv }
        format.xls { send_data @inbound_users.to_csv(col_sep: "\t") }
        format.json { render json: InboundDatatable.new(view_context, @inbound_users) }
      end
    end
  end

  def inbound_crawl
    begin
      running_crawl = InboundLink.where(is_processing: true)
      if running_crawl.exists?
        flash[:notice] = "&#x1f61e;&nbsp;&nbsp;You can run only one crawl at a time!<br/>Already one crawling process is running"
      else
        inbound_link = InboundLink.find(params[:id].to_s)
        raise if inbound_link.blank?
        call_rake "inbound:crawl", crawl_url: inbound_link.link
        puts "Rake Task Started for the url: #{inbound_link.link}"
        inbound_link.update(is_processing: true)
        flash[:notice] = "&#x263A;&nbsp;&nbsp;Crawl Started Successfully!"
      end
      redirect_to inbound_path
    rescue Exception => e
      flash[:alert] = "&#x1f61e;&nbsp;&nbsp;InboundLink not exists in our CRM"
      redirect_to inbound_path
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

  def call_rake(task, options = {})
    options[:rails_env] ||= Rails.env
    args = options.map { |n, v| "#{n.to_s.upcase}='#{v}'"}
    rake_cmd = "bundle exec rake #{task} #{args.join(' ')} --trace 2>&1 >> #{Rails.root}/log/crawl_inbound_rake.log &"
    # Task executes in the system
    system "cd #{Rails.root.to_s};#{rake_cmd}"
  end
end
