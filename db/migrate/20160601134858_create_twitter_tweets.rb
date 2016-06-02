class CreateTwitterTweets < ActiveRecord::Migration
  def change
    create_table :twitter_tweets do |t|
      t.text :tweet
      t.string :tweet_id
      t.string :user_id
      t.string :username
      t.string :tweet_link
      t.string :profile_link
      t.timestamps null: false
    end
  end
end
