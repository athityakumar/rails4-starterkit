class PipecandyMailer < ApplicationMailer
  
  layout "pipecandy_user_mailer", only: [:concierge_user_mail]

  def concierge_mail(prospect)
    @prospect = prospect
    mail(to: "ashwin@pipecandy.com", bcc: "suriyah@pipecandy.com", subject: "Someone is interested in Concierge - PipeCandy")
  end

  def concierge_user_mail(prospect)
    @prospect = prospect
    @prospect_name = prospect.blank? ? "" : prospect.name.blank? ? "" : prospect.name.split(" ").first.to_s
    mail(to: prospect.email, subject: "#{@prospect_name}, I got the note you left on PipeCandy")
  end

  def twitter_autofollow_error error_subject, error_message
    @error_message = error_message
    mail(to: "rajesh@pipecandy.com", subject: error_subject)
  end

  def twitter_update_followback_status_mailer followers, new_follower_ids
    @followers = followers
    @new_follower_ids = new_follower_ids
    mail(to: "rajesh@pipecandy.com, ashwin@pipecandy.com", subject: "Twitter Follow Update - New Follow Back Friends For PipeCandy! @ #{Time.now}")
  end

  def twitter_rake_success status, twitter_ids=[]
    @status = status
    @twitter_ids = twitter_ids
    mail(to: "rajesh@pipecandy.com", subject: "Twitter #{@status.to_s.capitalize} Success at #{Time.now}")
  end

  def twitter_fetch_create_follower_error error_message
    @error_message = error_message
    mail(to: "rajesh@pipecandy.com", subject: "Twitter - Fetch & Create Followers Error at #{Time.now}")
  end

  def twitter_fetch_create_follower name
    @username = name
    mail(to: "rajesh@pipecandy.com", subject: "Twitter - Fetch & Create Followers Added at #{Time.now}")
  end

   def inbound_fetch_create_error error_message
    @error_message = error_message
    mail(to: "athityakumar@gmail.com", subject: "Inbound - Fetch & Create Users Error at #{Time.now}")
  end

end
