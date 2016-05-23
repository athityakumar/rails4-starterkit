class CreateInboundUsers < ActiveRecord::Migration
  def change
    create_table :inbound_users do |t|
      t.string :name
      t.string :inbound_link
      t.string :twitter_link
      t.string :facebook_link
      t.string :linkedin_link
      t.string :googleplus_link
      t.string :name
      t.string :location
      t.string :designation
      t.string :company
      t.integer :number_followers
      t.integer :number_following
      t.integer :number_badges
      t.integer :karma
      t.text :badges
      t.string :recent_activity
      t.boolean :following, default: false
      t.boolean :follower, default: false
      t.date :date_processed
      t.integer :attempts, default: 0
      t.string :image_url
      t.string :userid
      t.timestamps null: false
    end
  end
end
