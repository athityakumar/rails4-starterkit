class PipecandyMailer < ApplicationMailer

  def concierge_mail(prospect)
    @prospect = prospect
    mail(to: "ashwin@pipecandy.com", subject: "Someone is interested in Concierge - PipeCandy")
  end

  def twitter_autofollow_error error_subject, error_message, twitter_ids=nil
    @error_message = error_message
    @twitter_ids = twitter_ids
    mail(to: "thangadurai@contractiq.com", subject: error_subject)
  end

  def twitter_update_followback_status_mailer following, new_following_ids
    @following = following
    @new_following_ids = new_following_ids
    mail(to: "thangadurai@contractiq.com", subject: "Twitter Follow Update - New Follow Back Friends For PipeCandy! @ #{Time.now}")
  end

  def twitter_rake_success status
    @status = status
    mail(to: "thangadurai@contractiq.com", subject: "Twitter #{@status.to_s.capitalize} Success at #{Time.now}")
  end

end
