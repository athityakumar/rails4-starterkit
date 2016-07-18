class CreateTrackingAws < ActiveRecord::Migration
  def change
    create_table :tracking_aws do |t|
    	t.string :message_id
    	t.string :email
    	t.string :bounce_type
    	t.string :bounce_status
    	t.string :bounce_action
    	t.string :complaint
    	t.string :complaint_feedback
    	t.string :delivered

      t.timestamps null: false
    end
    add_index :tracking_aws, [:email, :message_id], unique: true
  end
end
