class CreateInboundLinks < ActiveRecord::Migration
  def change
    create_table :inbound_links do |t|
      t.string :link
      t.boolean :is_processing, default: false
      t.date :date_processed
      
      t.timestamps null: false
    end
  end
end
