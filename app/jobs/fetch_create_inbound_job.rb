require "inbound_scraper_client"

class FetchCreateInboundJob < ActiveJob::Base
  
  queue_as :inbound_job

  def perform input_url
   mechanize = InboundScraperClient.api
   flag_count = 1
   prev_final = 0
   # prev_final = prev_final.to_s
   magic = prev_final
   accept_url = input_url
   profile_card = ".panel-body .avatar-offset h4 > a"

   if input_url.include? "search"
    profile_card = ".user-profile-card .profile-link > a"
   else 
    if input_url.include? "job_id"
      edit_url = input_url.gsub("job_id=","per_page=")
    elsif input_url.include? "members/"
      input_url = input_url.gsub("members/","members")
      edit_url = input_url+"/all/hot?&per_page=" 
    else
      edit_url = input_url
      magic = "" 
    end
    accept_url = edit_url + magic.to_s
   end 

   pagemain = mechanize.get(accept_url)
   named_list = pagemain.search(profile_card)
   pagination = 1

   while named_list.count != 0 do
    i = 0
    while i < named_list.count do
     sleep 5
     begin
      inbound_link = named_list[i]['href']
      if inbound_link.include? "inbound"
      else
       inbound_link = "https://inbound.org" + inbound_link
      end 
      i = i + 1
      today_date = Date.today 
      crawl_url = inbound_link
      page = mechanize.get(crawl_url)
      name = page.search('.member-details h1')[0].children.text.to_s
      karma = page.search('.member .karma')[0].text.gsub(",","").to_i
      number_followers = page.search('.member-following-container a')[0].text.to_i
      number_following = page.search('.member-following-container a')[1].text.to_i
      image_url = page.search(".member img")[0]['src']
      btn = page.at('.toggle-follow-user')
      userid = btn["data-user-id"]
      if page.search('.member-banner-tagline p').count != 0
       designation = page.search('.member-banner-tagline p')[0].text.rpartition("at")[0].gsub("\n"," ").lstrip.rstrip.strip.squeeze
      else
       designation = ""
      end
      if page.search('.member-details-container a').count != 0
       company =  page.search('.member-details-container a')[0].children.text
      else
       company = ""
      end
      if page.search('.member-details-container p').count >= 2
       location = page.search('.member-details-container p')[1].text
      else
       location = ""
      end
      if page.search('.member-details-container .twitter').count != 0
       twitter_link = page.search('.member-details-container .twitter')[0]['href']
      else 
       twitter_link = ""
      end
      if page.search('.member-details-container .facebook').count != 0
       facebook_link = page.search('.member-details-container .facebook')[0]['href']
      else
       facebook_link = ""
      end
      if page.search('.member-details-container .linkedin').count != 0 
       linkedin_link = page.search('.member-details-container .linkedin')[0]['href']
      else
       linkedin_link = ""
      end
      if page.search('.member-details-container .google-plus').count != 0
       googleplus_link = page.search('.member-details-container .google-plus')[0]['href']
      else
       googleplus_link = ""
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
      badges = ""
      number_badges = page.search(".profile-summary-content .karma_title").count
      k = number_badges - 1
      j = 0
      if number_badges != 0
       while j < number_badges do
        badges = badges + page.search(".profile-summary-content .karma_title")[j].text
        if j < k
          badges = badges + " , "
        end
        j = j + 1
       end 
      end
      InboundUser.create(name: name, inbound_link: inbound_link, twitter_link: twitter_link, facebook_link: facebook_link, linkedin_link: linkedin_link, googleplus_link: googleplus_link, location: location, designation: designation, company: company, number_followers: number_followers, number_following: number_following, number_badges: number_badges, karma: karma, badges: badges, recent_activity: recent_activity, userid: userid, image_url: image_url)
      puts "Hi"
     rescue Mechanize::ResponseCodeError => e
      PipecandyMailer.inbound_fetch_create_error("#{e.to_s}").deliver_now
     end
    end
    i = 0
    if input_url.include? "search"
     break
    else
     magic = pagination * 48
     pagination = pagination + 1 
     next_url = accept_url + "&per_page=" + magic.to_s
     accept_url = next_url 
     pagemain = mechanize.get(accept_url)
     named_list = pagemain.search('.panel-body .avatar-offset h4 > a')
    end
   end
  end
end
