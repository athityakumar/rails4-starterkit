require 'mechanize'
require 'date'
require 'resolv-replace'
require 'logger'

namespace :inbound do

  mechanize = Mechanize.new
  mechanize.log = Logger.new "log/mechanize.log"
  mechanize.history_added = Proc.new { sleep 5 }
  mechanize.follow_meta_refresh = true 
  mechanize.verify_mode = OpenSSL::SSL::VERIFY_NONE
  login_page = mechanize.get("https://inbound.org/login")
  logged_in = login_page.search(".modal-content .form-login").count

  if logged_in != 0
    mechanize.post("https://inbound.org/authenticate/check", {
      email: "ashwin@pipecandy.com",
      password: "pipecandy0302"
    })
    mechanize.cookie_jar.save_as "log/inbound.cookie", session: true, format: :yaml
    puts "Logged in"
  else
    mechanize.cookie_jar.load "log/inbound.cookie"
  end

  desc "Inbound auto update for all users in pipecandy DB"
  task update: :environment do

    puts "=================== Starting Inbound auto update for all users in DB => #{Time.now.to_s}=================="
    InboundUser.all.each do |user|
      begin
        today_date = Date.today 
        crawl_url = user.inbound_link
        page = mechanize.get(crawl_url)
        user.name = page.search('.member-details h1')[0].children.text.to_s
        user.karma = page.search('.member .karma')[0].text.gsub(",","").to_i
        user.number_followers = page.search('.member-following-container a')[0].text.to_i
        user.number_following = page.search('.member-following-container a')[1].text.to_i
        user.image_url = page.search(".member img")[0]['src']
        btn = page.at('.toggle-follow-user')
        user.userid = btn["data-user-id"]
        
        if page.search('.member-banner-tagline p').count != 0
         user.designation = page.search('.member-banner-tagline p')[0].text.rpartition("at")[0].gsub("\n"," ").lstrip.rstrip.strip.squeeze
        else
         user.designation = ""
        end
        
        if page.search('.member-details-container a').count != 0
         user.company =  page.search('.member-details-container a')[0].children.text
        else
         user.company = ""
        end
        
        if page.search('.member-details-container p').count >= 2
         user.location = page.search('.member-details-container p')[1].text
        else
         user.location = ""
        end
        
        if page.search('.member-details-container .twitter').count != 0
         user.twitter_link = page.search('.member-details-container .twitter')[0]['href']
        else 
         user.twitter_link = ""
        end
        
        if page.search('.member-details-container .facebook').count != 0
         user.facebook_link = page.search('.member-details-container .facebook')[0]['href']
        else
         user.facebook_link = ""
        end
        
        if page.search('.member-details-container .linkedin').count != 0 
         user.linkedin_link = page.search('.member-details-container .linkedin')[0]['href']
        else
         user.linkedin_link = ""
        end
        
        if page.search('.member-details-container .google-plus').count != 0
         user.googleplus_link = page.search('.member-details-container .google-plus')[0]['href']
        else
         user.googleplus_link = ""
        end
        
        if page.search('.activity-row .activity-list-submitted').count != 0
         recent_activity = page.search('.activity-row .activity-list-submitted')[0].text
         if recent_activity.include? "ag"
          recent_activity = recent_activity.to_i
          recent_activity = (today_date - recent_activity)
          recent_activity = recent_activity.strftime('%b %d %Y')
         end
        else
         recent_activity = "" 
        end
        user.recent_activity = recent_activity
        
        user.badges = ""
        user.number_badges = page.search(".profile-summary-content .karma_title").count
        
        k = user.number_badges - 1
        j = 0
        if user.number_badges != 0
         while j < user.number_badges do
          user.badges = user.badges + page.search(".profile-summary-content .karma_title")[j].text
          if j < k
            user.badges = user.badges + " , "
          else
            user.badges = user.badges + "."
          end
          j = j + 1
         end 
        end
        user.save
      rescue Mechanize::ResponseCodeError => e
        user.destroy
        PipecandyMailer.inbound_fetch_create_error("#{e.to_s}").deliver_now
        next
      rescue Exception => e
        PipecandyMailer.inbound_fetch_create_error("#{e.to_s}").deliver_now
        next       
      end
    end
    puts "===================Ending Inbound auto update for followers in DB => #{Time.now.to_s}=================="
    mechanize.get("https://inbound.org/logout")

  end  

  desc "Inbound Follow Feature"
  task follow: :environment do
    puts "================Starting Inbound Following => #{Time.now.to_s}================"
    puts "Inbound following starts Here..................."
    sample_to_be_followed = InboundUser.where("follower = 0 AND following = 0 AND attempts < 4").order(:attempts).first(50)
    unless sample_to_be_followed.blank?
      sample_to_be_followed.each do |user|
       sleep 5
       page = mechanize.get(user.inbound_link)
       mechanize.get("https://inbound.org/members/follow?user_id=#{user.userid}&follow=1")
       user.following = 1
       user.date_processed = Date.today.to_date
       user.save
      end
    end
    puts "Inbound following ends Here..................."  
    puts "================Ending Inbound Following => #{Time.now.to_s}================"
    mechanize.get("https://inbound.org/logout")

  end

  desc "Inbound Unfollow Feature"
  task unfollow: :environment do
    puts "================Starting Inbound UnFollowing => #{Time.now.to_s}================"
    puts "Inbound UnFollowing Starts Here..................."
    #sample_to_be_unfollowed = InboundUser.where("following = true AND follower = false AND date_processed = #{(Date.today - 0.days).to_s}").order(:attempts).last(10)   
    sample_to_be_unfollowed = InboundUser.where(following: true, follower: false, date_processed: (Date.today - 5.days).to_s).order(:attempts).last(50)
    unless sample_to_be_unfollowed.blank?
     sample_to_be_unfollowed.each do |user|
       sleep 5
       page = mechanize.get(user.inbound_link)
       mechanize.get("https://inbound.org/members/follow?user_id=#{user.userid}&follow=0")
       user.following = 0
       user.date_processed = Date.today.to_date
       user.attempts = user.attempts + 1
       user.save
     end
    end  
    puts "Inbound UnFollowing Ends Here..................."
    puts "================Ending Inbound UnFollowing => #{Time.now.to_s}================"
    mechanize.get("https://inbound.org/logout")

  end

end
