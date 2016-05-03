# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
set :output, '/home/pipecandy/engagement_cronlog.log'

# Friends status update task
["1.00 am", "5.30 am", "10.00 am", "2.30 pm", "7.00 pm", "11.30 pm"].each do |at|
  every :day, at: at do
    rake 'twitter_follow_unfollow:update_status'
  end
end

# Rake task to follow 20 followers at a time
["2.30 am", "7.00 am", "11.30 am", "4.00 pm"].each do |at|
  every :day, at: at do
    rake 'twitter_follow_unfollow:follow'
  end
end

# Rake task to follow 20 followers at a time
["4.00 am", "8.30 am", "1.00 pm", "5.30 pm"].each do |at|
  every :day, at: at do
    rake 'twitter_follow_unfollow:unfollow'
  end
end