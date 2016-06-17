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
    mail(to: "sathishkumar@ideas2it.com", subject: error_subject)
  end

  def inbound_error error_subject, error_message
    @error_message = error_message
    mail(to: "sathishkumar@ideas2it.com", bcc: "athityakumar@gmail.com", subject: error_subject)
  end

  # Admin Daily Notification Mailer
  def admin_notification_twitter new_followers
    @new_followers = new_followers
    mail(to: "ashwin@pipecandy.com", bcc: "sathishkumar@ideas2it.com", subject: "Twitter New Followers Status - Admin | Pipecandy")
  end
end
