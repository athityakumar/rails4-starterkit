class HomeController < ApplicationController
  
  def index
  end

  def email_process
    Email.create(email_params)
    redirect_to thank_you_path
  end

  def new_index
    concierge_cookie = request.cookies["pipecandy_concierge"]
    @show_concierge_request_access = true
    unless concierge_cookie.blank?
      email = concierge_cookie.to_s
      if Concierge.where(email: email).any?
        @show_concierge_request_access = false
      end
    end
  end

  def concierge_process
    email = params[:concierge][:email].to_s
    if Concierge.where(email: email).any?
      cookies.permanent[:pipecandy_concierge] = email
    else
      @concierge = Concierge.new(concierge_params)
      cookies.permanent[:pipecandy_concierge] = email if @concierge.save
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
