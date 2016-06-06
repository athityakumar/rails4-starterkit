namespace :admin_notification do
  
  desc "Admin Twitter Status Mailer"
  task twitter: :environment do
    puts "Admin Twitter Follow Back User Details mailer... Starts at #{Time.now.to_s}"
    twitter_followers = TwitterFollower.where(date_processed: Date.yesterday.to_s)
    PipecandyMailer.admin_notification_twitter(twitter_followers).deliver_now
    puts "Admin Twitter Follow Back User Details mailer... Ends at #{Time.now.to_s}"
  end

end
