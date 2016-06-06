class PipecandyMailer < ApplicationMailer
  
  layout "pipecandy_user_mailer", only: [:concierge_user_mail]

  def concierge_mail(prospect)
    @prospect = prospect
    mail(to: "ashwin@pipecandy.com", bcc: "suriyah@pipecandy.com", subject: "Someone is interested in Concierge - PipeCandy")
  end

  def concierge_user_mail(prospect)
    @prospect = prospect
    @prospect_name = prospect.blank? ? "" : prospect.name.blank? ? "" : prospect.name.split(" ").first.to_s
    mail(from: "ashwin@pipecandy.com", to: prospect.email, subject: "#{@prospect_name}, I got the note you left on PipeCandy")
  end

  def twitter_autofollow_error error_subject, error_message
    @error_message = error_message
    mail(to: "thangadurai@contractiq.in", subject: error_subject)
  end

  def twitter_update_followback_status_mailer followers, new_follower_ids
    @followers = followers
    @new_follower_ids = new_follower_ids
    mail(to: "thangadurai@contractiq.in", subject: "Twitter Follow Update - New Follow Back Friends For PipeCandy! @ #{Time.now}")
  end

  def twitter_rake_success status, twitter_ids=[]
    @status = status
    @twitter_ids = twitter_ids
    mail(to: "thangadurai@contractiq.in", subject: "Twitter #{@status.to_s.capitalize} Success at #{Time.now}")
  end

  def twitter_fetch_create_follower_error error_message
    @error_message = error_message
    mail(to: "thangadurai@contractiq.in", subject: "Twitter - Fetch & Create Followers Error at #{Time.now}")
  end

  def twitter_fetch_create_follower name
    @username = name
    mail(to: "thangadurai@contractiq.in", subject: "Twitter - Fetch & Create Followers Added at #{Time.now}")
  end

  def inbound_error error_subject, error_message
    @error_message = error_message
    mail(to: "thangadurai@contractiq.in", bcc: "athityakumar@gmail.com", subject: error_subject)
  end

  # Admin Daily Notification Mailer
  def admin_notification_twitter new_followers
    @new_followers = new_followers
    mail(to: "thangadurai@contractiq.in", subject: "Twitter New Followers Status - Admin | Pipecandy")
  end
end
