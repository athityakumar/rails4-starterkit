class AddTweetsToTwitterFollowers < ActiveRecord::Migration
  def change
    add_column :twitter_followers, :tweets, :text
  end
end
