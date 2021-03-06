require "fake_twitter_client"

class FetchCreateFollowerJob < ActiveJob::Base
  queue_as :twitter_followers_job

  def perform twitter_user
    begin
      puts "Start Fetch Followers and Create for Users............#{twitter_user.name.to_s}......#{Time.now}"
      # Get the twitter_client
      twitter_client = FakeTwitterClient.api
      # Get the follower_ids
      follower_ids = twitter_client.follower_ids(twitter_user.name)
      # Sleep for 6 seconds
      sleep 6
      # Process follower_ids
      new_twitter_ids = []
      follower_ids.each_slice(100).with_index do |slice, i|
        unless slice.blank?
          sleep_time = slice.count * 6
          twitter_client.users(slice).each_with_index do |f, j|
            # push all twitter ids into array
            new_twitter_ids.push(f.id.to_i)
            twitter_follower_hash = {
              name: f.name.to_ascii, 
              screen_name: f.screen_name.to_ascii, 
              twitter_id: f.id,
              profile_image_url: f.profile_image_url,
              location: f.location.to_ascii,
              profile_created_at: f.created_at.to_datetime,
              follow_request_sent: f.follow_request_sent?,
              url: f.url,
              followers_count: f.followers_count,
              protected_profile: f.protected?,
              description: f.description.to_ascii,
              verified: f.verified?,
              time_zone: f.time_zone.to_ascii,
              statuses_count: f.statuses_count,
              friends_count: f.friends_count
            }
            twitter_follower = TwitterFollower.find_by(twitter_id: f.id)
            if twitter_follower.blank?
              twitter_user.twitter_followers.create(twitter_follower_hash)
            else
              twitter_follower_hash.delete(:twitter_id)
              twitter_follower.update(twitter_follower_hash)
              # Create Association between user and followers 
              TwitterUserFollower.create_twitter_user_follower(twitter_user.id, twitter_follower.id)
            end
          end
          # Next request after sleep time (Approximation by best case).
          puts "Sleep for #{sleep_time.to_s} seconds"
          sleep sleep_time
        end
        puts "====================== Processing Iteration #{i}"
      end
      # Delete the old unwanted data to protect follow feature from failure
      old_twitter_ids = twitter_user.twitter_followers.pluck(:twitter_id).map(&:to_i)
      old_lookup_ids =  old_twitter_ids - new_twitter_ids
      twitter_user.twitter_followers.where("twitter_id IN (?)", old_lookup_ids).destroy_all
      # Update the twitter_user processing status to false
      TwitterUser.find(twitter_user.id).update(is_processing: false)
      puts "End Fetch Followers and Create for Users............#{twitter_user.name.to_s}......#{Time.now}"
    rescue Exception => e
      puts "Something else went wrong: #{e.to_s}"
      PipecandyMailer.twitter_autofollow_error("Twitter - Fetch & Create Followers Error at #{Time.now}", "#{e.to_s}").deliver_now
      # Update the twitter_user processing status to false
      TwitterUser.find(twitter_user.id).update(is_processing: false)
    end
  end
end
