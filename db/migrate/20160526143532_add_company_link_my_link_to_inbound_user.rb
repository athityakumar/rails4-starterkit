class AddCompanyLinkMyLinkToInboundUser < ActiveRecord::Migration
  def change
    add_column :inbound_users, :company_link, :string
    add_column :inbound_users, :my_link, :string
  end
end
