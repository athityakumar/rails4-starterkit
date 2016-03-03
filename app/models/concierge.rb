class Concierge < ActiveRecord::Base
  validates :name, presence: true, length: {minimum: 5, maximum: 50}
  validates :email, presence: true, uniqueness: true, format: { with: /\A([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})\Z/i, on: :create }
  validates :company, presence: true, length: {minimum: 5}
  validates :description, presence: true, length: {minimum: 10}
end
