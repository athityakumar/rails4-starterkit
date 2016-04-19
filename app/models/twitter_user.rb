class TwitterUser < ActiveRecord::Base
  # Relation between follower and mapping table
  has_many :twitter_user_followers
  has_many :twitter_followers, through: :twitter_user_followers
  # Validation
  validates :name, presence: true, uniqueness: true
end
