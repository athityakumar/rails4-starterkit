class Admin::AwsController < ApplicationController
	before_filter :authenticate!,  :except => [:bounce, :complaint, :delivered]
	skip_before_action :verify_authenticity_token, only: [:bounce, :complaint, :delivered]
	before_filter :respond_to_aws_sns_subscription_confirmations, only: [:bounce, :complaint, :delivered]

	def bounce
		begin
			raise unless params[:candy_token] == "90078359cb94c2401bb7dc6e4d68ac32"
			PipecandyMailer.developer_mails("aws", params.inspect).deliver_now
			puts params.inspect
			render nothing: true, status: 200
		rescue Exception => e
			render nothing: true, status: 500
		end
	end

	def complaint
		begin
			raise unless params[:candy_token] == "02abbe35eecc06b40e4e9794d097be46"
			PipecandyMailer.developer_mails("aws", params.inspect).deliver_now
			puts params.inspect
			render nothing: true, status: 200
		rescue Exception => e
			render nothing: true, status: 500
		end
	end

	def delivered
		begin
			raise unless params[:candy_token] == "227d6bc3c8858f21c1ab216c79ff1ed2"
			PipecandyMailer.developer_mails("aws", params.inspect).deliver_now
			puts params.inspect
			render nothing: true, status: 200
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

end
