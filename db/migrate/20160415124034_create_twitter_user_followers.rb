class CreateTwitterUserFollowers < ActiveRecord::Migration
  def change
    create_table :twitter_user_followers do |t|
      t.integer :twitter_user_id
      t.integer :twitter_follower_id

      t.timestamps null: false
    end
  end
end
