class CreateTwitterTweets < ActiveRecord::Migration
  def change
    create_table :twitter_tweets do |t|
      t.text :tweet
      
      t.timestamps null: false
    end
  end
end
