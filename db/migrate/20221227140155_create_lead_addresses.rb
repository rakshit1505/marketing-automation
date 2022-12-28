class CreateLeadAddresses < ActiveRecord::Migration[6.0]
  def change
    create_table :lead_addresses do |t|
      t.string :street_address
      t.string :city
      t.string :state
      t.string :country
      t.string :zip_code
      t.integer :lead_id
      t.timestamps
    end
  end
end
