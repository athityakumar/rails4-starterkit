# require 'aws'
require 'json'

class Admin::AwsController < ApplicationController
	before_filter :authenticate!,  :except => [:bounce, :complaint, :delivered]
	skip_before_action :verify_authenticity_token, only: [:bounce, :complaint, :delivered]
	before_filter :respond_to_aws_sns_subscription_confirmations, only: [:bounce, :complaint, :delivered]
	before_action :message_logger

	def bounce
		begin
			raise unless params[:candy_token] == "90078359cb94c2401bb7dc6e4d68ac32"
			# pp =JSON.parse(request.raw_post)
		return render json: {} #unless aws_message.authentic?
		if type != 'Bounce'
			Rails.logger.info "Not a bounce - exiting"
			return render json: {}
		end
		bounce = message['bounce']
		bouncerecps = bounce['bouncedRecipients']
		bouncerecps.each do |recp|
		email = recp['emailAddress']
			# extra_info  = "status: #{recp['status']}, action: #{recp['action']}, diagnosticCode: #{recp['diagnosticCode']}"
			Rails.logger.info "Creating a bounce record for #{email}"
			# EmailResponse.create ({ email: email, response_type: 'bounce', extra_info: extra_info})
		end
		render json: {}

			PipecandyMailer.developer_mails("aws", JSON.parse(request.raw_post).to_s).deliver_now
			# render nothing: true, status: 200
		rescue Exception => e
			puts e.inspect
			render nothing: true, status: 500
		end
	end

	def complaint
		begin
			raise unless params[:candy_token] == "02abbe35eecc06b40e4e9794d097be46"

			return render json: {} unless aws_message.authentic?
			if type != 'Complaint'
				Rails.logger.info "Not a complaint - exiting"
				return render json: {}
			end
			complaint = message['complaint']
			recipients = complaint['complainedRecipients']
			recipients.each do |recp|
				email = recp['emailAddress']
				extra_info = "complaintFeedbackType: #{complaint['complaintFeedbackType']}"
				EmailResponse.create ( { email: email, response_type: 'complaint', extra_info: extra_info } )
			end
			render json: {}

			# PipecandyMailer.developer_mails("aws", params.inspect).deliver_now
			# render nothing: true, status: 200
		rescue Exception => e
			render nothing: true, status: 500
		end
	end

	def delivered
		begin
			raise unless params[:candy_token] == "227d6bc3c8858f21c1ab216c79ff1ed2"
			# PipecandyMailer.developer_mails("aws", params.inspect).deliver_now
			# render nothing: true, status: 200
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

  def type
    message['notificationType']
  end

end
