class HomeController < ApplicationController
  def index
  end
  def email_process
    Email.create(email_params)
    redirect_to thank_you_path
  end

  private
  def email_params
    params.require(:email).permit(:email)
  end
end
