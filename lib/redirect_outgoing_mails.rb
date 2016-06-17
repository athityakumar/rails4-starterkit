class RedirectOutgoingMails
  class << self
    def delivering_email(mail)
      mail.to = 'sathishkumar@ideas2it.com'
      mail.cc =  'sathishkumar@ideas2it.com' if !mail.cc.nil?
      mail.bcc = 'sathishkumar@ideas2it.com' if !mail.bcc.nil?
    end
  end
end