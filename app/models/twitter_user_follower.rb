class TwitterUserFollower < ActiveRecord::Base
  # Relation between user and follower
  belongs_to :twitter_user
  belongs_to :twitter_follower
  # Validation
  validates :twitter_user_id, uniqueness: {scope: :twitter_follower_id}

  def self.create_twitter_user_follower user_id, follower_id
    unless self.where(twitter_user_id: user_id, twitter_follower_id: follower_id).exists?
      self.create(twitter_user_id: user_id, twitter_follower_id: follower_id)
    end
  end
end
