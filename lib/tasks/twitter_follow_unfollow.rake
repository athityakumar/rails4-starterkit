require "pipecandy_twitter_client"

namespace :twitter_follow_unfollow do

  desc "Twitter Follow Feature"
  task follow: :environment do
    puts "================Starting Twitter Following => #{Time.now.to_s}================"
    begin
      puts "Twitter following starts Here..................."
      unfollowed = TwitterFollower.where("followers = 0 AND following = 0 AND attempts < 4")
      unfollowed_ids = unfollowed.pluck(:twitter_id).sample(10).map(&:to_i)
      unless unfollowed_ids.blank?
        PipecandyTwitterClient.api.follow(unfollowed_ids)
        TwitterFollower.where("twitter_id IN (?)", unfollowed_ids).update_all(following: true, date_processed: Date.today.to_s)
        PipecandyMailer.twitter_rake_success("follow", unfollowed_ids).deliver_now
      end
      puts "Twitter following ends Here..................."
    rescue Exception => e
      puts "Something else went wrong: #{e.to_s}"
      PipecandyMailer.twitter_autofollow_error("Twitter - Follow exception errors", "#{e.to_s}").deliver_now
    end
    puts "================Ending Twitter Following => #{Time.now.to_s}================"
  end

  desc "Twitter Unfollow Feature"
  task unfollow: :environment do
    puts "================Starting Twitter UnFollowing => #{Time.now.to_s}================"
    begin
      puts "Twitter UnFollowing Starts Here..................."
      notfriendfollowed = TwitterFollower.where(following: true, followers: false, date_processed: (Date.today - 5.days).to_s)
      notfriendfollowed_ids = notfriendfollowed.pluck(:twitter_id).sample(10).map(&:to_i)
      unless notfriendfollowed_ids.blank?
        PipecandyTwitterClient.api.unfollow(notfriendfollowed_ids)
        TwitterFollower.where("twitter_id IN (?)", notfriendfollowed_ids).update_all("following = 0, attempts = attempts + 1")
        PipecandyMailer.twitter_rake_success("unfollow", notfriendfollowed_ids).deliver_now
      end
      puts "Twitter UnFollowing Ends Here..................."
    rescue Exception => e
      puts "Something else went wrong: #{e.to_s}"
      PipecandyMailer.twitter_autofollow_error("Twitter - Unfollow exception errors", "#{e.to_s}").deliver_now
    end
    puts "================Ending Twitter UnFollowing => #{Time.now.to_s}================"
  end

end
