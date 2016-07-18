class Admin::AwsController < ApplicationController
	before_filter :authenticate!,  :except => [:bounce, :complaint, :delivered]

	def bounce
		begin
			PipecandyMailer.developer_mails("aws", params.inspect).deliver_now
			puts params.inspect
			render nothing: true, status: 200
		rescue Exception => e
			puts e
			render nothing: true, status: 500
		end
	end

	def complaint
		begin
			PipecandyMailer.developer_mails("aws", params.inspect).deliver_now
			puts params.inspect
			render nothing: true, status: 200
		rescue Exception => e
			puts e
			render nothing: true, status: 500
		end
	end

	def delivered
		begin
			PipecandyMailer.developer_mails("aws", params.inspect).deliver_now
			puts params.inspect
			render nothing: true, status: 200
		rescue Exception => e
			puts e
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
