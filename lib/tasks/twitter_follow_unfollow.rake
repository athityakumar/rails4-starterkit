require "twitter_module_original"
namespace :twitter_follow_unfollow do
  
  desc "Twitter auto update API for follow back and friend status"
  task update_status: :environment do
    puts "===================Starting Twitter Update Follow Back And Friend Status => #{Time.now.to_s}=================="
    begin
      puts "Twitter Update Status Starts Here..................."
      customFilter = Proc.new { |f| {name: f.name, screen_name: f.screen_name, twitter_id: f.id} }
      idFilter = Proc.new { |x| x[:twitter_id] }

      # Following back
      followers = TwitterModuleOriginal.client.followers.map(&customFilter)
      follower_ids = followers.map(&idFilter).map(&:to_i)
      old_follower_ids = TwitterFollower.where(followers: true).pluck(:twitter_id).map(&:to_i)
      new_follower_ids = follower_ids - old_follower_ids
      unless new_follower_ids.blank?
        # Update the followers id
        TwitterFollower.where("twitter_id IN (?)", new_follower_ids).update_all(followers: true)
        PipecandyMailer.twitter_update_followback_status_mailer(followers, new_follower_ids).deliver_now
      end

      puts "Sleeping for 1 minute"
      sleep 900
      puts "Wake up at #{Time.now}"

      # Friends update
      following = TwitterModuleOriginal.client.friends.map(&customFilter)
      following_ids = following.map(&idFilter).map(&:to_i)
      old_following_ids = TwitterFollower.where(following: true).pluck(:twitter_id).map(&:to_i)
      new_following_ids = following_ids - old_following_ids
      unless new_following_ids.blank?
        # Update the friend id status
        TwitterFollower.where("twitter_id IN (?)", new_following_ids).update_all(following: true)
      end

      puts "Twitter Update Status Ends Here..................."
    rescue Twitter::Error::Unauthorized
      error_handle("Twitter - Update Status Error", "Not authorized error occurs, when try to twitter_follow", [])    
      puts "Not authorized. Ask developer check the twitter credentials in the code!"
    rescue Twitter::Error::TooManyRequests => e
      error_handle("Twitter - Update Status TooManyRequests Retry before", "Too Many Request. It's going to retry after #{e.rate_limit.reset_in} seconds. Now time is #{Time.now.to_s}", [])
      puts "TooManyRequests: #{e.rate_limit.reset_in}"
      sleep e.rate_limit.reset_in
      error_handle("Twitter - Update Status TooManyRequests Retry after", "Too Many Request. It's going to retry. Now time is #{Time.now.to_s}", [])
      retry
    rescue Twitter::Error::Forbidden => e
      error_handle("Twitter - Update Status Forbidden error", "#{e.to_s}", [])
      puts "Forbidden error: #{e.to_s}"
    rescue Exception => e
      error_handle("Twitter - Update Status exception errors", "#{e.to_s}", [])
      puts "Something else went wrong: #{e.to_s}"
    end
    puts "===================Ending Twitter Update Follow Back And Friend Status => #{Time.now.to_s}=================="
  end

  desc "Twitter Follow Feature"
  task follow: :environment do
    puts "================Starting Twitter Following => #{Time.now.to_s}================"
    unfollowed = TwitterFollower.where("followers = 0 AND following = 0 AND attempts < 4")
    unfollowed_ids = unfollowed.sample(20).map(&:twitter_id).map(&:to_i)

    begin
      puts "Twitter Following Starts Here..................."
      if unfollowed_ids.blank?
        puts "DB is empty?................"
      else
        TwitterModuleOriginal.client.follow(unfollowed_ids)
        TwitterFollower.where("twitter_id IN (?)", unfollowed_ids).update_all(following: true, date_processed: Date.today.to_s)
        PipecandyMailer.twitter_rake_success("follow", unfollowed_ids).deliver_now
      end
      puts "Twitter Following Ends Here..................."
    rescue Twitter::Error::Unauthorized
      error_handle("Twitter - Follow Authorize Error", "Not authorized error occurs, when try to twitter_follow", unfollowed_ids)    
      puts "Not authorized. Ask developer check the twitter credentials in the code!"
    rescue Twitter::Error::TooManyRequests => e
      error_handle("Twitter - Follow TooManyRequests Retry before", "Too Many Request. It's going to retry after #{e.rate_limit.reset_in} seconds. Now time is #{Time.now.to_s}", unfollowed_ids)
      puts "TooManyRequests: #{e.rate_limit.reset_in}"
      sleep e.rate_limit.reset_in
      error_handle("Twitter - Follow TooManyRequests Retry after", "Too Many Request. It's going to retry. Now time is #{Time.now.to_s}", unfollowed_ids)
      retry
    rescue Twitter::Error::Forbidden => e
      error_handle("Twitter - Follow Forbidden error", "#{e.to_s}", unfollowed_ids)
      puts "Forbidden error: #{e.to_s}"
    rescue Exception => e
      error_handle("Twitter - Follow exception errors", "#{e.to_s}", unfollowed_ids)
      puts "Something else went wrong: #{e.to_s}"
    end

    puts "================Ending Twitter Following => #{Time.now.to_s}================"
  end

  desc "Twitter Unfollow Feature"
  task unfollow: :environment do
    puts "================Starting Twitter UnFollowing => #{Time.now.to_s}================"
    notfriendfollowed = TwitterFollower.where(following: true, followers: false, date_processed: (Date.today - 5.days).to_s)
    notfriendfollowed_ids = notfriendfollowed.pluck(:twitter_id).sample(20).map(&:to_i)

    begin
      puts "Twitter UnFollowing Starts Here..................."
      if notfriendfollowed_ids.blank?
        puts "DB is empty?................"
      else
        TwitterModuleOriginal.client.unfollow(notfriendfollowed_ids)
        TwitterFollower.where("twitter_id IN (?)", notfriendfollowed_ids).update_all("following = 0, attempts = attempts + 1")
        PipecandyMailer.twitter_rake_success("unfollow", notfriendfollowed_ids).deliver_now
      end
      puts "Twitter UnFollowing Ends Here..................."
    rescue Twitter::Error::Unauthorized
      error_handle("Twitter - UnFollow Authorize Error", "Not authorized error occurs, when try to twitter_unfollow", notfriendfollowed_ids)    
      puts "Not authorized. Ask developer check the twitter credentials in the code!"
    rescue Twitter::Error::TooManyRequests => e
      error_handle("Twitter - UnFollow TooManyRequests Retry before", "Too Many Request. It's going to retry after #{e.rate_limit.reset_in} seconds. Now time is #{Time.now.to_s}", notfriendfollowed_ids)
      puts "TooManyRequests: #{e.rate_limit.reset_in}"
      sleep e.rate_limit.reset_in
      error_handle("Twitter - UnFollow TooManyRequests Retry after", "Too Many Request. It's going to retry. Now time is #{Time.now.to_s}", notfriendfollowed_ids)
      retry
    rescue Twitter::Error::Forbidden => e
      error_handle("Twitter - UnFollow Forbidden error", "#{e.to_s}", notfriendfollowed_ids)
      puts "Forbidden error: #{e.to_s}"
    rescue Exception => e
      error_handle("Twitter - UnFollow exception errors", "#{e.to_s}", notfriendfollowed_ids)
      puts "Something else went wrong: #{e.to_s}"
    end

    puts "================Ending Twitter UnFollowing => #{Time.now.to_s}================"
  end

  # Twitter follow unfollow error notification to email
  def error_handle subject, message, twitter_ids
    PipecandyMailer.twitter_autofollow_error(subject, message, twitter_ids).deliver_now
  end
end
