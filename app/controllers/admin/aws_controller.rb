require 'json'
class Admin::AwsController < ApplicationController
	before_filter :authenticate!,  :except => [:bounce, :complaint, :delivered]
	skip_before_action :verify_authenticity_token, only: [:bounce, :complaint, :delivered]
	before_filter :respond_to_aws_sns_subscription_confirmations, only: [:bounce, :complaint, :delivered]
	before_action :message_logger, only: [:bounce, :complaint, :delivered]

	def bounce
		begin
			raise unless params[:candy_token] == "90078359cb94c2401bb7dc6e4d68ac32"
			if notification_type != 'Bounce'
				Rails.logger.info "Not a bounce - exiting"
				return render json: {}
			end
			bounce = message['bounce']
			bnc = bounce['bouncedRecipients']
			bnc.each do |recp|
			email = recp['emailAddress']
				puts message_id.to_s
				@tracking_aws = TrackingAws.where(message_id: message_id, email: email).first
				if @tracking_aws.blank?
					TrackingAws.create(message_id: message_id, email: email, notification_type: notification_type , bounce_status: bounce['bounceType'], bounce_action:recp['action'], sender: sender)
				else
					TrackingAws.update(notification_type: notification_type , bounce_status: bounce['bounceType'], bounce_action:recp['action'], sender: sender)
				end
			end
			PipecandyMailer.developer_mails("aws | bounce", JSON.parse(request.raw_post)).deliver_now
			render json: {}
		rescue Exception => e
			render nothing: true, status: 500
		end
	end

	def complaint
		begin
			raise unless params[:candy_token] == "02abbe35eecc06b40e4e9794d097be46"
			if notification_type != 'Complaint'
				Rails.logger.info "Not a complaint - exiting"
				return render json: {}
			end
			complaint= message['complaint']
			complaint['complainedRecipients'].each do |recp|
				email = recp['emailAddress']
				@tracking_aws = TrackingAws.where(message_id: message_id, email: email).first
				if @tracking_aws.blank?
					TrackingAws.create(message_id: message_id, email: email, notification_type: notification_type, complaint_feedback: message['feedbackId'], sender: sender)
				else
					@tracking_aws.update(notification_type: notification_type, complaint_feedback: message['feedbackId'], sender: sender)
				end
			end
			PipecandyMailer.developer_mails("aws | complaint", JSON.parse(request.raw_post)).deliver_now
			render json: {}
		rescue Exception => e
			render nothing: true, status: 500
		end
	end

	def delivered
		begin
			raise unless params[:candy_token] == "227d6bc3c8858f21c1ab216c79ff1ed2"
			PipecandyMailer.developer_mails("aws | delivered", JSON.parse(request.raw_post)).deliver_now
			render json: {}
		rescue Exception => e
			render nothing: true, status: 500
		end
	end

	def view
		begin
			render nothing: true, status:200
		rescue Exception => e
			render nothing: true, status:500
		end
	end

	protected

	def aws_message
    @aws_message ||= Aws::SNS::Client.new request.raw_post
  end

	def message_logger
    Rails.logger.info request.raw_post
  end

  def message
    @message ||= JSON.parse JSON.parse(request.raw_post)['Message']
  end

  def notification_type
    message['notificationType']
  end

  def message_id
  	JSON.parse(request.raw_post)['MessageId'].to_s
  end

  def sender
  	message['mail']['source']
  end

end
