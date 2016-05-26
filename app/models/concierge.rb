require 'csv'

class Concierge < ActiveRecord::Base
  validates :name, presence: true, length: {minimum: 5, maximum: 50}
  validates :email, presence: true, uniqueness: true, format: { with: /\A([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})\Z/i, on: :create }
  validates :company, presence: true, length: {minimum: 5}

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << [:id, :name, :email, :company, :description, :created_at]
      all.each do |concierge|
        csv << [concierge.id, concierge.name, concierge.email, concierge.company, concierge.description, concierge.created_at.strftime('%b %d %Y')]
      end
    end
  end
end
