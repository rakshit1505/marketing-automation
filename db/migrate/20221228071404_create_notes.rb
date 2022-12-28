class CreateNotes < ActiveRecord::Migration[6.0]
  def change
    create_table :notes do |t|
      t.integer :user_id
      t.integer :lead_id
      t.string :title
      t.string :description
      t.integer :attachment_id
      t.timestamps
    end
  end
end
