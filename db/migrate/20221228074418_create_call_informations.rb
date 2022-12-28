class CreateCallInformations < ActiveRecord::Migration[6.0]
  def change
    create_table :call_informations do |t|
      t.integer :lead_id
      t.integer :call_type_id
      t.datetime :start_time
      t.integer :user_id
      t.string  :call_owner
      t.string :subject
      t.string :reminder
      t.string :status
      t.timestamps
    end
  end
end
