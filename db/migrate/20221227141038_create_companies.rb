class CreateCompanies < ActiveRecord::Migration[6.0]
  def change
    create_table :companies do |t|
      t.string :last_name
      t.string :website
      t.string :social_media_handle
      t.integer :company_id
      t.timestamps
    end
  end
end
