class Admin::AwsController < ApplicationController
	before_filter :authenticate!,  :except => [:bounce, :complaint, :delivered]

	def bounce
		begin
			render nothing: true, status: 200
		rescue Exception => e
			render nothing: true, status: 500
		end
	end

	def complaint
		begin
			render nothing: true, status: 200
		rescue Exception => e
			render nothing: true, status: 500
		end
	end

	def delivered
		begin
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
