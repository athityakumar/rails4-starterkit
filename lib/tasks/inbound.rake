# Require the inbound scraper client library
require "inbound_scraper_client"

namespace :inbound do

  # Get the inbound scraper client
  $scraper = InboundScraperClient.api

  # Get the next page link
  def next_page page
    next_element = page.search("ul.pagination li").at("li.active").next_element
    # Return Next Element
    return next_element.nil? ? nil : next_element.at("a")["href"]
  end

  # Get the inbound user details
  def get_inbound_user_data page
    # Profile Related Info
    profile_details = page.search('div.member-banner div.member')
    # User ID
    userid_ele = profile_details.at("div.member-banner-following > a.toggle-follow-user")
    userid = userid_ele.nil? ? nil : userid_ele["data-user-id"]
    # Name
    name_ele = profile_details.at("div.member-details h1")
    name = name_ele.nil? ? nil : name_ele.text.strip.to_ascii
    # Company and its link
    company_link_ele = profile_details.at("div.member-banner-tagline p:nth-of-type(1) a")
    if company_link_ele.nil?
      company, company_link = nil, nil
    else
      company, company_link = company_link_ele.text, company_link_ele["href"]
    end
    # Image
    image_ele = profile_details.at("img.avatar")
    image = image_ele.nil? ? nil : image_ele["src"].strip
    # Location
    location_ele = profile_details.at("div.member-banner-tagline p:nth-of-type(2)")
    location = location_ele.nil? ? nil : location_ele.text.strip.to_ascii
    # Title
    title_ele = profile_details.at("div.member-banner-tagline p:nth-of-type(1)")
    title = title_ele.nil? ? nil : title_ele.children.first.text.strip.gsub(" at", "").to_ascii
    # Karma
    karma_ele = profile_details.at("span.karma")
    karma = karma_ele.nil? ? nil : karma_ele.children.first.text.strip.delete(",").to_i
    # Followers
    followers = profile_details.at("ul > li.member-banner-followers-count a").children.first.text.strip.to_i
    # Following
    following = profile_details.at("ul > li.member-banner-following-count a").children.first.text.strip.to_i
    # Twitter Link
    tw_link_ele = profile_details.at("div.social-links i.fa-twitter")
    tw_link = tw_link_ele.nil? ? nil : tw_link_ele.parent["href"]
    # Facebook Link
    fb_link_ele = profile_details.at("div.social-links i.fa-facebook")
    fb_link = fb_link_ele.nil? ? nil : fb_link_ele.parent["href"]
    # Linkedin Link
    in_link_ele = profile_details.at("div.social-links i.fa-linkedin")
    in_link = in_link_ele.nil? ? nil : in_link_ele.parent["href"]
    # Google Plus Link
    gplus_link_ele = profile_details.at("div.social-links i.fa-google-plus")
    gplus_link = gplus_link_ele.nil? ? nil : gplus_link_ele.parent["href"]
    # Website Link
    web_link_ele = profile_details.at("div.social-links i.fa-link")
    web_link = web_link_ele.nil? ? nil : web_link_ele.parent["href"]
    # Badges
    badges_ele = page.search("div.profile-summary-content span.karma_title")
    if badges_ele.nil?
      number_badges, badges = nil, nil
    else
      badges = badges_ele.map(&:text).map(&:to_s).map(&:strip)
      number_badges = badges.count
    end
    # Recent Activity
    recent_activity_ele = page.search("li.activity-row span.activity-list-submitted")
    recent_activity = recent_activity_ele.blank? ? nil : recent_activity_ele.first.text.to_s.strip
    unless recent_activity.blank?
      if recent_activity.include?("ag") || recent_activity.include?("ago")
        # eval() is a function in ruby used to execute the part of code
        recent_activity = eval(recent_activity.downcase.strip.gsub(" ", ".")).strftime('%b %d %Y')
      end
    end
    # return all the data as hash
    return {
      userid: userid,
      name: name,
      company: company,
      company_link: company_link,
      image_url: image,
      location: location,
      designation: title,
      karma: karma,
      number_followers: followers,
      number_following: following,
      twitter_link: tw_link,
      facebook_link: fb_link,
      linkedin_link: in_link,
      googleplus_link: gplus_link,
      my_link: web_link,
      number_badges: number_badges,
      badges: badges,
      recent_activity: recent_activity
    }
  end

  # Recursive function to crawl the all pages
  def iterate_search_page search_page
    begin
      page = $scraper.get(search_page)
      user_profile_links = page.links_with(class: "avatar", href: %r{https://inbound.org/in/}).map(&:href)
      user_profile_links.each do |inbound_link|
        # If user not already in our crm, Add it to crm.
        # Otherwise Update it
        inbound_user = InboundUser.find_by(inbound_link: inbound_link)
        # Hash of inbound user data
        puts "Crawling Profile ...: #{inbound_link.to_s}"
        profile = $scraper.get(inbound_link)
        inbound_user_data = get_inbound_user_data profile
        if inbound_user.blank?
          InboundUser.create(inbound_user_data.merge(inbound_link: inbound_link))
        else
          inbound_user.update(inbound_user_data)
        end
      end
      # Check if next page exist
      next_search_page = next_page(page)
      puts "Next page: #{next_search_page.to_s}"
      if next_search_page.nil?
        return true
      else
        puts "Recursive Iteration ...\n"
        puts "Sleep for 10 seconds."
        sleep 10
        puts "Proceeding next page crawling..."
        iterate_search_page next_search_page
      end
    rescue Exception => e
      puts "Error Message: #{e.to_s}"
      PipecandyMailer.inbound_error("Crawl Inbound User and Add it to CRM exception errors", "#{e.to_s}").deliver_now
    end
  end

  desc "Crawl Inbound User and Add it to CRM"
  task crawl: :environment do
    puts "Start Crawling Inbound.org #{Time.now.to_s}....."
    # iterate_search_page function is a recursive algorithm
    # Getting crawl url from user
    crawl_done = iterate_search_page ENV["CRAWL_URL"]
    # Update the is_processing to false
    InboundLink.find_by(link: ENV["CRAWL_URL"]).update(is_processing: false, date_processed: Date.today.to_s)
    puts "End Crawling Inbound.org #{Time.now.to_s}....."    
  end

  desc "Inbound Follow Feature"
  task follow: :environment do
    begin
      puts "Start Following Inbound.org #{Time.now.to_s}....."
      unfollowed = InboundUser.where("follower = 0 AND following = 0 AND attempts < 4")
      unfollowed_ids = unfollowed.order(:attempts).pluck(:userid).first(25)
      unless unfollowed_ids.blank?
        unfollowed_ids.each do |id|
          puts "Inbound follow user id: #{id.to_s}..."
          $scraper.get("https://inbound.org/members/follow?user_id=#{id}&follow=1")
          sleep 2
        end
        InboundUser.where("userid IN (?)", unfollowed_ids).update_all(following: true, date_processed: Date.today.to_s)
      end
      puts "End Following Inbound.org #{Time.now.to_s}....."
    rescue Exception => e
      puts "Error Message: #{e.to_s}"
      PipecandyMailer.inbound_error("Inbound Follow Feature exception errors", "#{e.to_s}").deliver_now
    end
  end

  desc "Inbound Unfollow Feature"
  task unfollow: :environment do
    begin
      puts "Start unFollowing Inbound.org #{Time.now.to_s}....."
      notfriendfollowed = InboundUser.where(following: true, follower: false, date_processed: (Date.today - 5.days).to_s)
      notfriendfollowed_ids = notfriendfollowed.order(:attempts).pluck(:userid).last(25)
      unless notfriendfollowed_ids.blank?
        notfriendfollowed_ids.each do |id|
          puts "Inbound unfollow user id: #{id.to_s}..."
          $scraper.get("https://inbound.org/members/follow?user_id=#{id}&follow=0")
          sleep 2
        end
        InboundUser.where("userid IN (?)", notfriendfollowed_ids).update_all("following = 0, attempts = attempts + 1, date_processed = #{Date.today.to_s}")
      end
      puts "End unFollowing Inbound.org #{Time.now.to_s}....."
    rescue Exception => e
      puts "Error Message: #{e.to_s}"
      PipecandyMailer.inbound_error("Inbound Unfollow Feature exception errors", "#{e.to_s}").deliver_now
    end
  end

  desc "Update Follower Status in CRM"
  task followers: :environment do
    begin
      puts "Start getting followers from Inbound.org #{Time.now.to_s}....."
      page = $scraper.get("https://inbound.org/in/pipecandyhq/followers")
      follower_inbound_links = page.links_with(class: "avatar", href: %r{https://inbound.org/in/}).map(&:href)
      InboundUser.where("inbound_link IN (?)", follower_inbound_links).update_all(follower: true)
      puts "End getting followers from Inbound.org #{Time.now.to_s}....."
    rescue Exception => e
      puts "Error Message: #{e.to_s}"
      PipecandyMailer.inbound_error("Update Follower Status in CRM exception errors", "#{e.to_s}").deliver_now
    end
  end

  desc "Update following Status in CRM"
  task following: :environment do
    begin
      puts "Start getting following from Inbound.org #{Time.now.to_s}....."
      page = $scraper.get("https://inbound.org/in/pipecandyhq/following")
      following_inbound_links = page.links_with(class: "avatar", href: %r{https://inbound.org/in/}).map(&:href)
      InboundUser.where("inbound_link IN (?)", following_inbound_links).update_all(following: true)
      puts "End getting following from Inbound.org #{Time.now.to_s}....."
    rescue Exception => e
      puts "Error Message: #{e.to_s}"
      PipecandyMailer.inbound_error("Update following Status in CRM exception errors", "#{e.to_s}").deliver_now
    end
  end

end
