class CreateTwitterFollowers < ActiveRecord::Migration
  def change
    create_table :twitter_followers do |t|
      t.string :name
      t.string :screen_name
      t.string :twitter_id
      t.boolean :following, default: false
      t.boolean :followers, default: false
      t.date :date_processed
      t.integer :attempts, default: 0

      t.timestamps null: false
    end
    add_index :twitter_followers, :screen_name, unique: true
  end
end
