class TrackingAw < ActiveRecord::Base
	add_index :tracking_aws, [:email, :message_id], unique: true
end
