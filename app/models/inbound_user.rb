class InboundUser < ActiveRecord::Base
  # Validation
  validates :inbound_link, presence: true, uniqueness: true
end
