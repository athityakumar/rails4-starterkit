# Learn more: http://github.com/javan/whenever
set :output, '/home/pipecandy/engagement_cronlog.log'

# Follower status update task
["9.15 am", "7.15 pm"].each do |at|
  every :day, at: at do
    rake "twitter_status:followers"
  end
end

# Following status update task
["9.45 am", "7.45 pm"].each do |at|
  every :day, at: at do
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
