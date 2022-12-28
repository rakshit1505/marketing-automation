class CreateLeads < ActiveRecord::Migration[6.0]
  def change
    create_table :leads do |t|
      t.string :first_name
      t.string :last_name
      t.string :email_id
      t.string :phone_number
      t.string :company_id
      t.string :title
      t.integer :lead_source_id
      t.integer :lead_status_id
      t.string :industry
      t.string :company_size
      t.string :website
      t.integer :address_id
      t.integer :lead_rating_id
      t.timestamps
    end
  end
end
