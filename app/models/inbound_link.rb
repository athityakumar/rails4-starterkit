class InboundLink < ActiveRecord::Base
  # Validation
  validates :link, presence: true, uniqueness: true
end
