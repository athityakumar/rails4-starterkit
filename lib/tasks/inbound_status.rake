require "inbound_scraper_client"

namespace :inbound_status do

  desc "Update follower status in CRM"
  task followers: :environment do
    puts "===================Starting Inbound auto update for followers in DB => #{Time.now.to_s}=================="
    begin
      puts "Inbound Update Status Starts Here..................."
      my_profile = "https://inbound.org/in/pipecandyhq/followers"
      page = InboundScraperClient.api.get(my_profile)
      follower_inbound_links = page.links_with(class: "avatar", href: %r{https://inbound.org/in/}).map(&:href)
      InboundUser.where("inbound_link IN (?)", follower_inbound_links).update_all(follower: true)
    rescue Mechanize::ResponseCodeError => e
      puts "Error Message: #{e.to_s}"
      PipecandyMailer.inbound_autofollow_error("Inbound - Update for follower status exception errors", "#{e.to_s}").deliver_now
    rescue Exception => e
      puts "Error Message: #{e.to_s}"
      PipecandyMailer.inbound_autofollow_error("Inbound - Update for follower status exception errors", "#{e.to_s}").deliver_now
    end
    puts "===================Ending Inbound auto update for followers in DB => #{Time.now.to_s}=================="
  end

  desc "Update following status in CRM"
  task following: :environment do
    puts "===================Starting Inbound auto update for following in DB => #{Time.now.to_s}=================="
    begin
      puts "Inbound Update Status Starts Here..................."
      my_profile = "https://inbound.org/in/pipecandyhq/following"
      page = InboundScraperClient.api.get(my_profile)
      following_inbound_links = page.links_with(class: "avatar", href: %r{https://inbound.org/in/}).map(&:href)
      InboundUser.where("inbound_link IN (?)", following_inbound_links).update_all(following: true)
    rescue Mechanize::ResponseCodeError => e
      puts "Error Message: #{e.to_s}"
      PipecandyMailer.inbound_autofollow_error("Inbound - Update for following status exception errors", "#{e.to_s}").deliver_now
    rescue Exception => e
      puts "Error Message: #{e.to_s}"
      PipecandyMailer.inbound_autofollow_error("Inbound - Update for following status exception errors", "#{e.to_s}").deliver_now
    end
    puts "===================Ending Inbound auto update for following in DB => #{Time.now.to_s}=================="
  end

end
