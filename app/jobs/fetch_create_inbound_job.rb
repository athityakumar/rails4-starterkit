require "inbound_scraper_client"

class FetchCreateInboundJob < ActiveJob::Base
  
  queue_as :inbound_job

  # Initialize the scraper
  $scraper = InboundScraperClient.api

  # Get the next page link
  def next_page page
    begin
      next_element = page.search("ul.pagination li").at("li.active").next_element
      # Return Next Element
      return next_element.nil? ? nil : next_element.at("a")["href"]
    rescue Exception => e
      puts e
    end
  end

  def get_inbound_user_data inbound_link
    # Initialize Inbound user
    page = $scraper.get(inbound_link)
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
        recent_activity = eval(recent_activity.downcase.gsub(" ", ".")).strftime('%b %d %Y')
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
      inbound_link: inbound_link,
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

  # Iterate all page and store the links in user profile links page
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
        inbound_user_data = get_inbound_user_data inbound_link
        if inbound_user.blank?
          InboundUser.create(inbound_user_data)
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
        puts "Recursive Iterating ..."
        iterate_search_page next_search_page
      end
    rescue Exception => e
      puts e
    end
  end

  def perform search_url
    iterate_search_page search_url
  end
end
