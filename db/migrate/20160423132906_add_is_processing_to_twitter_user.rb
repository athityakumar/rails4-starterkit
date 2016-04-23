class AddIsProcessingToTwitterUser < ActiveRecord::Migration
  def change
    add_column :twitter_users, :is_processing, :boolean, default: false
  end
end
