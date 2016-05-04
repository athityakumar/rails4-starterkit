class PipecandyMailer < ApplicationMailer

  def concierge_mail(prospect)
    @prospect = prospect
    mail(to: "ashwin@pipecandy.com", subject: "Someone is interested in Concierge - PipeCandy")
  end

  def twitter_autofollow_error error_subject, error_message, twitter_ids=nil
    @error_message = error_message
    @twitter_ids = twitter_ids
    mail(to: "thangadurai@pipecandy.com", subject: error_subject)
  end

  def twitter_update_followback_status_mailer following, new_following_ids
    @following = following
    @new_following_ids = new_following_ids
    mail(to: "thangadurai@pipecandy.com, ashwin@pipecandy.com", subject: "Twitter Follow Update - New Follow Back Friends For PipeCandy! @ #{Time.now}")
  end

  def twitter_rake_success status, twitter_ids=[]
    @status = status
    @twitter_ids = twitter_ids
    mail(to: "thangadurai@pipecandy.com", subject: "Twitter #{@status.to_s.capitalize} Success at #{Time.now}")
  end

  def twitter_fetch_create_follower_error error_message
    @error_message = error_message
    mail(to: "thangadurai@pipecandy.com", subject: "Twitter - Fetch & Create Followers Error at #{Time.now}")
  end

  def twitter_fetch_create_follower name
    @username = name
    mail(to: "thangadurai@pipecandy.com", subject: "Twitter - Fetch & Create Followers Added at #{Time.now}")
  end

end
