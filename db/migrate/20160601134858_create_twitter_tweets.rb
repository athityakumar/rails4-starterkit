class CreateTwitterTweets < ActiveRecord::Migration
  def change
    create_table :twitter_tweets do |t|
      t.text :tweet
      t.string :tweet_hashtags
      t.string :tweet_id
      t.string :user_id
      t.string :user_screen_name
      t.string :tweet_link
      t.string :profile_link
      t.timestamps null: false
      t.string :tweet_user_mentions
      t.boolean :is_retweet, default: false
      t.string :tweet_timing
      t.integer :retweet_count
    end
  end
end
