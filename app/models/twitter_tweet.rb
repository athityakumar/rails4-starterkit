class TwitterTweet < ActiveRecord::Base

  # Relation between user and mapping table
  has_many :twitter_followers

  # Validations
  validates :tweet_id, presence: true, uniqueness: true
  validates :tweet , presence: true

end
