class CreateSmsOtps < ActiveRecord::Migration[6.0]
  def change
    create_table :sms_otps do |t|
      t.string :full_phone_number
      t.datetime :valid_untill
      t.integer :pin
      t.boolean :activated

      t.timestamps
    end
  end
end
