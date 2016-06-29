class AddAdminMailToTwitterFollower < ActiveRecord::Migration
  def change
    add_column :twitter_followers, :admin_mail, :boolean, default: false
  end
end
