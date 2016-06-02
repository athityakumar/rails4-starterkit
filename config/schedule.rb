# Learn more: http://github.com/javan/whenever
set :output, '/home/pipecandy/engagement_cronlog.log'
# TWITTER
# Follower and Following status update task
["1.50 am", "3.50 am", 
  "5.50 am", "7.50 am", 
  "11.50 am", "1.50 pm",
  "3.50 pm", "5.50 pm",
  "9.50 pm", "11.50pm"].each do |at|
  every :day, at: at do
    rake "twitter_status:followers"
    rake "twitter_status:following" 
  end
end

# Rake task to follow 10 followers at a time
["1.00 am", "3.00 am", 
  "5.00 am", "7.00 am", 
  "11.00 am", "1.00 pm", 
  "3.00 pm", "5.00 pm", 
  "9.00 pm", "11.00 pm"].each do |at|
  every :day, at: at do 
    rake "twitter_follow_unfollow:follow"
  end
end

# Rake task to unfollow 10 followers at a time
["2.00 am", "4.00 am", 
  "6.00 am", "8.00 am", 
  "12.00 am", "2.00 pm", 
  "4.00 pm", "6.00 pm", 
  "10.00 pm", "12.00 pm"].each do |at|
  every :day, at: at do
    rake "twitter_follow_unfollow:unfollow"
  end
end

# Rake task to listen to tweets 
# timing yet to be decided
timing.each do |at|
  every :day, at: at do
    rake "twitter_status:fetch_tweets"
  end
end



# INBOUND.ORG
# Rake task to follow 25 followers at a time in inbound
["5.00 am", "5.00 pm"].each do |at|
  every :day, at: at do 
    rake "inbound:follow"
  end
end

# Rake task to unfollow 25 followers at a time in inbound
["11.00 am", "11.00 pm" ].each do |at|
  every :day, at: at do 
    rake "inbound:unfollow"
  end
end

# Rake task for update followers/following to crm
["4.50 am", "10.50 am", "4.50 pm", "10.50 pm"].each do |at|
  every :day, at: at do
    rake "inbound:followers"
    rake "inbound:following"
  end
end
