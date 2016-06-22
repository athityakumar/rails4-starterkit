class RedirectOutgoingMails
  class << self
    def delivering_email(mail)
      mail.to = 'sathish@contractiq.in'
      mail.cc =  'sathish@contractiq.in' if !mail.cc.nil?
      mail.bcc = 'sathish@contractiq.in' if !mail.bcc.nil?
    end
  end
end