class PipecandyMailer < ApplicationMailer

  def concierge_mail(prospect)
    @prospect = prospect
    mail(to: "ashwin@pipecandy.com", subject: "Someone is interested in Concierge - PipeCandy")
  end

end
