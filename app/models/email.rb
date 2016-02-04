class Email < ActiveRecord::Base
  validates :email, presence: true, uniqueness: true, format: { with: /\A([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})\Z/i, on: :create }
end