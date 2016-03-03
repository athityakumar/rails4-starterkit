class HomeController < ApplicationController
  
  # def email_process
  #   Email.create(email_params)
  #   redirect_to thank_you_path
  # end

  def concierge_process
    @prospect = Concierge.new(concierge_params)
    if @prospect.save
      PipecandyMailer.concierge_mail(@prospect).deliver_now
    end
    redirect_to thank_you_path
  end

  def no_route_match_error
    params[:unmatched_route] = params[:unmatched_route].gsub( /\W/, '-' ).to_s
    if params[:unmatched_route] && !params[:unmatched_route].start_with?("uploads/") && !params[:unmatched_route].start_with?("assets/") && !params[:format]
      redirect_to root_path
    end
  end

  private

  def email_params
    params.require(:email).permit(:email)
  end

  def concierge_params
    params.require(:concierge).permit(:name, :email, :company, :description)
  end

end