class HomeController < ApplicationController
  
  def email_process
    Email.create(email_params)
    redirect_to thank_you_path
  end

  def concierge_process
    @prospect = Concierge.new(concierge_params)
    if @prospect.save
      PipecandyMailer.concierge_mail(@prospect).deliver_now
    end
    redirect_to thank_you_path
  end

  private

  def email_params
    params.require(:email).permit(:email)
  end

  def concierge_params
    params.require(:concierge).permit(:name, :email, :company, :description)
  end

end
