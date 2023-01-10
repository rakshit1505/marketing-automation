class CreatePotential < ActiveRecord::Migration[6.0]
  def change
    create_table :potentials do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.references :lead, null: false, foreign_key: true, index: true
      t.integer :status
      t.string :outcome

      t.timestamps
    end
  end
end
