require "twitter_module_fake"

class FetchCreateFollowerJob < ActiveJob::Base
  queue_as :twitter_followers_job

  def perform twitter_user
    begin
      puts "Start Fetch Followers and Create for Users............#{twitter_user.name.to_s}......#{Time.now}"
      # Get the twitter user followers
      twitter_followers = twitter_user.twitter_followers
      # Get the old Ids in the database
      old_followers_ids = twitter_followers.map(&:twitter_id).map(&:to_i)
      # Get the twitter_client
      twitter_client = TwitterModuleFake.client
      # Get the follower_ids
      follower_ids = twitter_client.follower_ids(twitter_user.name)
      # Sleep for 10 seconds
      sleep 10
      # Process follower_ids
      follower_ids.each_slice(100).with_index do |slice, i|
        slice = slice - old_followers_ids
        # dynamic sleep time
        sleep_time = slice.count * 6
        unless slice.blank?
          follower_hash = []
          twitter_client.users(slice).each_with_index do |f, j|
            follower_hash << {name: f.name, screen_name: f.screen_name, twitter_id: f.id}
          end
          # create follower associate with user
          twitter_user.twitter_followers.create(follower_hash)
          # Next request after 10 minutes.
          sleep sleep_time
        end
        puts "====================== Processing Iteration #{i}"
      end
      # Update the twitter_user processing status to false
      twitter_user.update(is_processing: false)
      PipecandyMailer.twitter_fetch_create_follower(twitter_user.name).deliver_now
      puts "End Fetch Followers and Create for Users............#{twitter_user.name.to_s}......#{Time.now}"
    rescue Twitter::Error::Unauthorized
      error_handle("Not authorized error occurs")    
      puts "Not authorized. Ask developer check the twitter credentials in the code!"
    rescue Twitter::Error::TooManyRequests => e
      error_handle("Too Many Request. It's going to retry after #{e.rate_limit.reset_in} seconds. Now time is #{Time.now.to_s}")
      puts "TooManyRequests: #{e.rate_limit.reset_in}"
      sleep e.rate_limit.reset_in
      error_handle("Too Many Request. It's going to retry. Now time is #{Time.now.to_s}")
      retry
    rescue Twitter::Error::Forbidden => e
      error_handle("#{e.to_s}")
      puts "Forbidden error: #{e.to_s}"
    rescue Exception => e
      error_handle("#{e.to_s}")
      puts "Something else went wrong: #{e.to_s}"
    end
  end

  private

  def error_handle message
    PipecandyMailer.twitter_fetch_create_follower_error(message).deliver_now
  end
end
