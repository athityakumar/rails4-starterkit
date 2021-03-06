class TwitterFollower < ActiveRecord::Base
  # Relation between user and mapping table
  has_many :twitter_user_followers, dependent: :destroy
  has_many :twitter_users, through: :twitter_user_followers
  # Validations
  validates :name, presence:true
  validates :twitter_id, presence: true, uniqueness: true
end
