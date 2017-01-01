namespace :admin_notification do
  
  desc "Admin Twitter Status Mailer"
  task twitter: :environment do
    puts "Admin Twitter Follow Back User Details mailer... Starts at #{Time.now.to_s}"
    twitter_followers = TwitterFollower.where(followers: true, admin_mail: false)
    PipecandyMailer.admin_notification_twitter(twitter_followers).deliver_now if twitter_followers.any?
    # before proceeding this deployment. Makesure all the TwitterFollower -> admin_mail fields are true for better results
    twitter_followers.each do |follower|
    	follower.update(admin_mail: true)
  	end
    puts "Admin Twitter Follow Back User Details mailer... Ends at #{Time.now.to_s}"
  end

end

namespace :ak do
  
  desc "Ak Mailer"
  task ak: :environment do
    PipecandyMailer.ak_mailer().deliver_now 
  end

end
