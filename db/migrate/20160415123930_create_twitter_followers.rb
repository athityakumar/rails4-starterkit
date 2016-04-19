class CreateTwitterFollowers < ActiveRecord::Migration
  def change
    create_table :twitter_followers do |t|
      t.string :name
      t.string :screen_name
      t.string :twitter_id
      t.boolean :is_friend, default: false
      t.boolean :is_following, default: false
      t.boolean :is_processed, default: false

      t.timestamps null: false
    end
    add_index :twitter_followers, :screen_name, unique: true
  end
end
