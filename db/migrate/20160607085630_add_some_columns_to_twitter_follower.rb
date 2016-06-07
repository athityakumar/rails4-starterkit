class AddSomeColumnsToTwitterFollower < ActiveRecord::Migration
  def change
    add_column :twitter_followers, :profile_image_url, :string
    add_column :twitter_followers, :location, :string
    add_column :twitter_followers, :profile_created_at, :datetime
    add_column :twitter_followers, :follow_request_sent, :boolean, default: false
    add_column :twitter_followers, :url, :string
    add_column :twitter_followers, :followers_count, :integer, default: 0
    add_column :twitter_followers, :protected_profile, :boolean, default: false
    add_column :twitter_followers, :description, :text
    add_column :twitter_followers, :verified, :boolean, default: false
    add_column :twitter_followers, :time_zone, :string
    add_column :twitter_followers, :statuses_count, :integer, default: 0
    add_column :twitter_followers, :friends_count, :integer, default: 0
  end
end
