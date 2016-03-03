class CreateConcierges < ActiveRecord::Migration
  def change
    create_table :concierges do |t|
      t.string :name
      t.string :email
      t.string :company
      t.string :description

      t.timestamps null: false
    end
  end
end
