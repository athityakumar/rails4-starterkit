class TwitterUserFollower < ActiveRecord::Base
  # Relation between user and follower
  belongs_to :twitter_user
  belongs_to :twitter_follower
  # Validation
  validates :twitter_user_id, uniqueness: {scope: :twitter_follower_id}
end
