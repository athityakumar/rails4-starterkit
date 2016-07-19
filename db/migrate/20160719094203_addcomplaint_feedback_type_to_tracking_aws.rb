class AddcomplaintFeedbackTypeToTrackingAws < ActiveRecord::Migration
  def change
  	add_column :tracking_aws, :complaint_feedback_type, :string
  end
end