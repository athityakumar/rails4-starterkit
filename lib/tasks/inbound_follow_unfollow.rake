require "inbound_scraper_client"

namespace :inbound_follow_unfollow do
 
  desc "Inbound Follow Feature"
  task follow: :environment do
    puts "================Starting Inbound Following => #{Time.now.to_s}================"
    begin
      puts "Inbound following starts Here..................."
      # Get the inbound scraper client from library
      scraper = InboundScraperClient.api
      unfollowed = InboundUser.where("follower = 0 AND following = 0 AND attempts < 4")
      unfollowed_ids = unfollowed.order(:attempts).pluck(:userid).first(50)
      unless unfollowed_ids.blank?
        unfollowed_ids.each do |id|
          scraper.get("https://inbound.org/members/follow?user_id=#{id}&follow=1")
          sleep 2
        end
        InboundUser.where("userid IN (?)", unfollowed_ids).update_all(following: true, date_processed: Date.today.to_s)
      end
      puts "Inbound following ends Here..................."
    rescue Exception => e
      puts "Something else went wrong: #{e.to_s}"
      PipecandyMailer.inbound_autofollow_error("Inbound - Follow exception errors", "#{e.to_s}").deliver_now
    end
    puts "================Ending Inbound Following => #{Time.now.to_s}================"
  end

  desc "Inbound Unfollow Feature"
  task unfollow: :environment do
    puts "================Starting Inbound UnFollowing => #{Time.now.to_s}================"
    begin
      puts "Inbound UnFollowing Starts Here..................."
      # Get the inbound scraper client from library
      scraper = InboundScraperClient.api
      notfriendfollowed = InboundUser.where(following: true, follower: false, date_processed: (Date.today - 5.days).to_s)
      notfriendfollowed_ids = notfriendfollowed.order(:attempts).pluck(:userid).last(50)
      unless notfriendfollowed_ids.blank?
        notfriendfollowed_ids.each do |id|
          scraper.get("https://inbound.org/members/follow?user_id=#{id}&follow=0")
          sleep 2
        end
        InboundUser.where("userid IN (?)", notfriendfollowed_ids).update_all("following = 0, attempts = attempts + 1, date_processed = #{Date.today.to_s}")
      end
      puts "Inbound UnFollowing Ends Here..................."
    rescue Exception => e
      puts "Something else went wrong: #{e.to_s}"
      PipecandyMailer.inbound_autofollow_error("Inbound - Unfollow exception errors", "#{e.to_s}").deliver_now
    end
    puts "================Ending Inbound UnFollowing => #{Time.now.to_s}================"
  end
  
end
