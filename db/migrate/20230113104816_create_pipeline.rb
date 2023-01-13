class CreatePipeline < ActiveRecord::Migration[6.0]
  def change
    create_table :pipelines do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.references :lead_source, null: false, foreign_key: true, index: true
      t.string :account_name
      t.integer :score
      t.datetime :journey
      t.integer :probability
      t.float :expected_revenue

      t.timestamps
    end
  end
end
