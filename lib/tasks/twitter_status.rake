require "pipecandy_twitter_client"

namespace :twitter_status do

  desc "Twitter auto update for followers in pipecandy DB"
  task followers: :environment do
    puts "===================Starting Twitter auto update for followers in DB => #{Time.now.to_s}=================="
    begin
      puts "Twitter Update Status Starts Here..................."
      # Following back
      follower_ids = PipecandyTwitterClient.api.follower_ids.map(&:to_i)
      old_follower_ids = TwitterFollower.where(followers: true).pluck(:twitter_id).map(&:to_i)
      new_follower_ids = follower_ids - old_follower_ids
      unless new_follower_ids.blank?
        # Update the followers id
        TwitterFollower.where("twitter_id IN (?)", new_follower_ids).update_all(followers: true)
        PipecandyMailer.twitter_update_followback_status_mailer(followers, new_follower_ids).deliver_now
      end
    rescue Exception => e
      puts "Something else went wrong: #{e.to_s}"
      PipecandyMailer.twitter_autofollow_error("Twitter - Update for follower 1 status exception errors", "#{e.to_s}").deliver_now
    end
    puts "===================Ending Twitter auto update for followers in DB => #{Time.now.to_s}=================="
  end

  desc "Twitter auto update for following in pipecandy DB"
  task following: :environment do
    puts "===================Starting Twitter auto update for following in DB => #{Time.now.to_s}=================="
    begin
      puts "Twitter Update Status Starts Here..................."
      # Friends update
      following_ids = PipecandyTwitterClient.api.friend_ids.map(&:to_i)
      old_following_ids = TwitterFollower.where(following: true).pluck(:twitter_id).map(&:to_i)
      new_following_ids = following_ids - old_following_ids
      unless new_following_ids.blank?
        # Update the friend id status
        TwitterFollower.where("twitter_id IN (?)", new_following_ids).update_all(following: true)
      end
    rescue Exception => e
      puts "Something else went wrong: #{e.to_s}"
      PipecandyMailer.twitter_autofollow_error("Twitter - Update for following 2 status exception errors", "#{e.to_s}").deliver_now
    end
    puts "===================Ending Twitter auto update for following in DB => #{Time.now.to_s}=================="
  end

end
