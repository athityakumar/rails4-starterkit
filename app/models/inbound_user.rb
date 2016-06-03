require 'csv'

class InboundUser < ActiveRecord::Base
  # Validation
  validates :inbound_link, presence: true, uniqueness: true

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << ["ID","Name","# Followers","# Following","Karma","Location","Designation","Company","Inbound Link","Twitter Link","Facebook Link","Linkedin Link","Google+ Link","User Link","Company Link"]
      all.each do |inbound|
        csv << [inbound.id, inbound.name, inbound.number_followers, inbound.number_following, inbound.karma, inbound.location, inbound.designation, inbound.company, inbound.inbound_link, inbound.twitter_link, inbound.facebook_link, inbound.linkedin_link, inbound.googleplus_link, inbound.my_link, inbound.company_link]
      end
    end
  end
end
