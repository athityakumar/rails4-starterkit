require "pipecandy_twitter_client"

class FetchCreateTweetJob < ActiveJob::Base
  queue_as :twitter_tweets_job

  def get_data tweet
    tweet_value = tweet.text
    tweet_id_value = tweet.id.to_s
    user_id_value = tweet.user.id.to_s
    username_value = tweet.user.screen_name
    profile_link_value = "https://twitter.com/"+username_value
    tweet_link_value = profile_link_value + "/status/" + tweet_id_value 
    return {
      tweet: tweet_value,
      tweet_id: tweet_id_value,
      user_id: user_id_value,
      username: username_value,
      tweet_link: tweet_link_value,
      profile_link: profile_link_value
    }
  end

  def perform 
    begin
      puts "Start Fetch Tweets from PipeCandy Timeline..................#{Time.now}"
      old_tweets = TwitterTweet.pluck(:tweet_id)
      tweets = PipecandyTwitterClient.api.home_timeline(count:150)
      unless tweets.empty?
        tweets.each do |tweet|
          unless old_tweets.include? tweet.id.to_s
            data = get_data(tweet)
            TwitterTweet.create(tweet)
          end
        end
      sleep 1000
      end

      TwitterUser.find(twitter_user.id).update(is_processing: false)
      PipecandyMailer.twitter_fetch_create_follower(twitter_user.name).deliver_now
      puts "End Fetch Followers and Create for Users............#{twitter_user.name.to_s}......#{Time.now}"
    rescue Exception => e
      puts "Something else went wrong: #{e.to_s}"
      PipecandyMailer.twitter_fetch_create_follower_error("#{e.to_s}").deliver_now
    end
  end
end
