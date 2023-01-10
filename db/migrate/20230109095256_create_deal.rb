class CreateDeal < ActiveRecord::Migration[6.0]
  def change
    create_table :deals do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.references :potential, null: false, foreign_key: true, index: true
      t.datetime :kick_off_date
      t.datetime :sign_off_date
      t.string :term
      t.string :tenure
      t.string :description
      t.integer :status

      t.timestamps
    end
  end
end
