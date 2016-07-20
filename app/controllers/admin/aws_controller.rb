require 'json'
class Admin::AwsController < ApplicationController
	before_filter :authenticate!, :except => [:bounce, :complaint, :delivered]
	skip_before_action :verify_authenticity_token, only: [:bounce, :complaint, :delivered]
	before_filter :respond_to_aws_sns_subscription_confirmations, only: [:bounce, :complaint, :delivered]
	before_action :message_logger, only: [:bounce, :complaint, :delivered]

	def bounce
		begin
			raise unless params[:candy_token] == "90078359cb94c2401bb7dc6e4d68ac32"
			message ||= JSON.parse JSON.parse(request.raw_post)['Message']
			notification_type = message['notificationType']
			message_id = JSON.parse(request.raw_post)['MessageId'].to_s
			sender = message['mail']['source']
			if notification_type != 'Bounce'
				Rails.logger.info "Not a bounce - exiting"
				return render json: {}
			end
			bounce = message['bounce']
			bnc = bounce['bouncedRecipients']
			bnc.each do |recp|
			email = recp['emailAddress']
				@tracking_aws = TrackingAws.where(message_id: message_id, email: email).first
				if @tracking_aws.blank?
					TrackingAws.create(message_id: message_id, email: email, notification_type: notification_type , bounce_status: bounce['bounceType'], bounce_action:recp['action'], sender: sender)
				else
					@tracking_aws.update(notification_type: notification_type , bounce_status: bounce['bounceType'], bounce_action:recp['action'], sender: sender)
				end
			end
			render json: {}
		rescue Exception => e
			render nothing: true, status: 500
		end
	end

	def complaint
		begin
			raise unless params[:candy_token] == "02abbe35eecc06b40e4e9794d097be46"
			message ||= JSON.parse JSON.parse(request.raw_post)['Message']
			notification_type = message['notificationType']
			message_id = JSON.parse(request.raw_post)['MessageId'].to_s
			sender = message['mail']['source']
			if notification_type != 'Complaint'
				Rails.logger.info "Not a complaint - exiting"
				return render json: {}
			end
			complaint= message['complaint']
			complaint['complainedRecipients'].each do |recp|
				email = recp['emailAddress']
				@tracking_aws = TrackingAws.where(message_id: message_id, email: email).first
				if @tracking_aws.blank?
					TrackingAws.create(message_id: message_id, email: email, notification_type: notification_type, complaint_feedback: message['feedbackId'], complaint_feedback_type: complaint['complaintFeedbackType'], sender: sender)
				else
					@tracking_aws.update(notification_type: notification_type, complaint_feedback: message['feedbackId'], complaint_feedback_type: complaint['complaintFeedbackType'], sender: sender)
				end
			end
			render json: {}
		rescue Exception => e
			render nothing: true, status: 500
		end
	end

	def delivered
		begin
			raise unless params[:candy_token] == "227d6bc3c8858f21c1ab216c79ff1ed2"
			message ||= JSON.parse JSON.parse(request.raw_post)['Message']
			notification_type = message['notificationType']
			message_id = JSON.parse(request.raw_post)['MessageId'].to_s
			sender = message['mail']['source']
			if notification_type != 'Delivery'
				Rails.logger.info "Not a Delivery - exiting"
				return render json: {}
			end
			delivered = message['delivery']
			email =  delivered['recipients'].first.gsub('\"','')
			@tracking_aws = TrackingAws.find_by(message_id: message_id,email: email)
			if @tracking_aws.blank?
				TrackingAws.create(message_id: message_id, email: email, notification_type: notification_type, delivered: "true",sender: sender)
			else
				@tracking_aws.update(notification_type: notification_type, delivered: "true", sender: sender)
			end
			render json: {}
		rescue Exception => e
			render nothing: true, status: 500
		end
	end

	def view_all
		@trackings = TrackingAws.all
		@tracking_bounce = TrackingAws.where('bounce_status IS NOT NULL OR bounce_action IS NOT NULL').paginate(:page => params[:bounce_page], :per_page => 30)
		@tracking_complaint = TrackingAws.where('complaint_feedback IS NOT NULL OR complaint_feedback_type IS NOT NULl').paginate(:page => params[:complaint_page], :per_page => 30)
		@tracking_delivered = TrackingAws.where('delivered = ?', 'true').paginate(:page => params[:delivered_page], :per_page => 30)
		@tracking_aws = @trackings.paginate(:page => params[:all_page], :per_page => 30)
		respond_to do |format|
      format.html
      format.csv { send_data @trackings.to_csv_aws }
    end
	end

	def view_bounce
		@trackings = TrackingAws.where('bounce_status IS NOT NULL OR bounce_action IS NOT NULL')
		@tracking_aws = @trackings.paginate(:page => params[:page], :per_page => 20)
		respond_to do |format|
      format.html
      format.csv { send_data @trackings.to_csv_aws }
    end
	end

	def view_complaint
		@trackings = TrackingAws.where('complaint_feedback IS NOT NULL OR complaint_feedback_type IS NOT NULl')
		@tracking_aws = @trackings.paginate(:page => params[:page], :per_page => 20)
		respond_to do |format|
      format.html
      format.csv { send_data @trackings.to_csv_aws }
    end
	end

	def view_delivered
		@trackings = TrackingAws.where('delivered = ?', 'true')
		@tracking_aws = @trackings.paginate(:page => params[:page], :per_page => 20)
		respond_to do |format|
      format.html
      format.csv { send_data @trackings.to_csv_aws }
    end
	end

	protected

	def aws_message
    @aws_message ||= Aws::SNS::Client.new request.raw_post
  end

	def message_logger
    Rails.logger.info request.raw_post
  end

  private
  def authenticate!
    authenticate_or_request_with_http_basic do |username, password|
      username == "pipecandy" && password == "pipecandy1905!"
    end
  end

end
