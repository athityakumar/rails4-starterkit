class TrackingAws < ActiveRecord::Base

	def self.to_csv_aws(options = {})
    CSV.generate(options) do |csv|
      csv << ['messageID','Email','Type','Bounce Status','Bounce Action', 'Complaint', 'Complaint Feedback', 'Delivered', 'Sender']
      all.each do |tracks|
        csv << tracks.attributes.values_at('message_id', 'email', 'notification_type', 'bounce_status','bounce_action', 'complaint_feedback', 'complaint_feedback_type', 'delivered', 'sender')
      end
    end
  end

end
