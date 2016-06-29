require "pipecandy_twitter_client"

namespace :twitter_status do

  desc "Twitter auto update for followers in pipecandy DB"
  task followers: :environment do
    puts "===================Starting Twitter auto update for followers in DB => #{Time.now.to_s}=================="
    begin
      puts "Twitter Update Status Starts Here..................."
      # Following back
      twitter_client = PipecandyTwitterClient.api
      follower_ids = twitter_client.follower_ids.map(&:to_i)
      # update the follower in DB
      TwitterFollower.where("twitter_id IN (?)", follower_ids).update_all(followers: true)
      # Update those followers info in DB
      follower_ids.each_slice(100).with_index do |slice, i|
        unless slice.blank?
          twitter_client.users(slice).each_with_index do |f, j|
            twitter_follower_hash = {
              name: f.name.to_ascii, 
              screen_name: f.screen_name.to_ascii,
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
              friends_count: f.friends_count,
              following: f.following?
            }
            twitter_follower = TwitterFollower.find_by(twitter_id: f.id)
            twitter_follower.update(twitter_follower_hash) unless twitter_follower.blank?
          end
          # Next request after 9 minutes 40 seconds (Approximation by best case).
          sleep 580
        end
        puts "====================== Processing Iteration #{i}"
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
      twitter_client = PipecandyTwitterClient.api
      following_ids = twitter_client.friend_ids.map(&:to_i)
      # update the following in DB
      TwitterFollower.where("twitter_id IN (?)", following_ids).update_all(following: true)
    rescue Exception => e
      puts "Something else went wrong: #{e.to_s}"
      PipecandyMailer.twitter_autofollow_error("Twitter - Update for following 2 status exception errors", "#{e.to_s}").deliver_now
    end
    puts "===================Ending Twitter auto update for following in DB => #{Time.now.to_s}=================="
  end

  desc "Twitter auto fetch tweets from Pipecandy's timeline & store meaningful ones in Pipecandy DB"
  task fetch_tweets: :environment do
    
  def get_data tweet
    tweet_value = tweet.text.strip.to_ascii
    for i in (0..tweet.hashtags.count-1)
      if i == 0
        tweet_hashtags_value = tweet.hashtags[i].text
      else 
        tweet_hashtags_value = tweet_hashtags_value + "," + tweet.hashtags[i].text
      end      
    end
    for i in (0..tweet.user_mentions.count-1)
      if i == 0
        tweet_user_mentions_value = tweet.user_mentions[i].screen_name
      else 
        tweet_user_mentions_value = tweet_user_mentions_value + "," + tweet.user_mentions[i].screen_name
      end      
    end
    if tweet.retweet?
      is_retweet_value = true
    else
      is_retweet_value = false
    end
    tweet_timing_value = tweet.created_at.to_s
    retweet_count_value = tweet.retweet_count
    # user_description_value = tweet.user.description
    tweet_id_value = tweet.id.to_s
    user_id_value = tweet.user.id.to_s
    user_screen_name_value = tweet.user.screen_name
    profile_link_value = "https://twitter.com/"+user_screen_name_value
    tweet_link_value = profile_link_value + "/status/" + tweet_id_value 
    return {
      tweet: tweet_value,
      tweet_hashtags: tweet_hashtags_value,
      tweet_user_mentions: tweet_user_mentions_value,
      is_retweet: is_retweet_value,
      tweet_timing: tweet_timing_value,
      retweet_count: retweet_count_value,
      tweet_id: tweet_id_value,
      user_id: user_id_value,
      user_screen_name: user_screen_name_value,
      tweet_link: tweet_link_value,
      profile_link: profile_link_value
    }
  end

    begin
      puts "Start Fetch Tweets from PipeCandy Timeline..................#{Time.now}"
      old_tweets = TwitterTweet.pluck(:tweet_id)
      tweets = PipecandyTwitterClient.api.home_timeline(count:150)
      unless tweets.empty?
        tweets.each do |tweet|
          unless old_tweets.include? tweet.id.to_s
            puts tweet.id.to_s
            data = get_data tweet
            TwitterTweet.create(data)
          end
        end
      sleep 1000
      end
      # PipecandyMailer.twitter_fetch_create_follower(twitter_user.name).deliver_now
      # puts "End Fetch Tweets............#{twitter_user.name.to_s}......#{Time.now}"
    rescue Exception => e
      puts "Something else went wrong: #{e.to_s}"
      # PipecandyMailer.twitter_fetch_create_follower_error("#{e.to_s}").deliver_now
    end
  end

  desc "Twitter auto fetch tweets from Pipecandy's timeline & store meaningful ones in Pipecandy DB"
 # task fetch_tweets_search:,query: :environment do
  task :fetch_tweets_search, [:query] => [:environment] do |t, args|  
  def get_data tweet
    tweet_value = tweet.text.strip.to_ascii
    for i in (0..tweet.hashtags.count-1)
      if i == 0
        tweet_hashtags_value = tweet.hashtags[i].text
      else 
        tweet_hashtags_value = tweet_hashtags_value + "," + tweet.hashtags[i].text
      end      
    end
    for i in (0..tweet.user_mentions.count-1)
      if i == 0
        tweet_user_mentions_value = tweet.user_mentions[i].screen_name
      else 
        tweet_user_mentions_value = tweet_user_mentions_value + "," + tweet.user_mentions[i].screen_name
      end      
    end
    if tweet.retweet?
      is_retweet_value = true
    else
      is_retweet_value = false
    end
    tweet_timing_value = tweet.created_at.to_s
    retweet_count_value = tweet.retweet_count
    # user_description_value = tweet.user.description
    tweet_id_value = tweet.id.to_s
    user_id_value = tweet.user.id.to_s
    user_screen_name_value = tweet.user.screen_name
    profile_link_value = "https://twitter.com/"+user_screen_name_value
    tweet_link_value = profile_link_value + "/status/" + tweet_id_value 
    return {
      tweet: tweet_value,
      tweet_hashtags: tweet_hashtags_value,
      tweet_user_mentions: tweet_user_mentions_value,
      is_retweet: is_retweet_value,
      tweet_timing: tweet_timing_value,
      retweet_count: retweet_count_value,
      tweet_id: tweet_id_value,
      user_id: user_id_value,
      user_screen_name: user_screen_name_value,
      tweet_link: tweet_link_value,
      profile_link: profile_link_value
    }
  end

    begin
      puts "Start Fetch Searched Tweets from Twitter..................#{Time.now}"
      old_tweets = TwitterTweet.pluck(:tweet_id)
      tweets = PipecandyTwitterClient.api.search(args[:query]).to_a
      unless tweets.empty?
        tweets.each do |tweet|
          unless old_tweets.include? tweet.id.to_s
            puts tweet.id.to_s
            data = get_data tweet
            TwitterTweet.create(data)
          end
        end
      sleep 1000
      end
      # PipecandyMailer.twitter_fetch_create_follower(twitter_user.name).deliver_now
      # puts "End Fetch Tweets............#{twitter_user.name.to_s}......#{Time.now}"
    rescue Exception => e
      puts "Something else went wrong: #{e.to_s}"
      # PipecandyMailer.twitter_fetch_create_follower_error("#{e.to_s}").deliver_now
    end
  end

end
