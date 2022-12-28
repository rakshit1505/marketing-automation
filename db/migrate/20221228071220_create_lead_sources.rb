class CreateLeadSources < ActiveRecord::Migration[6.0]
  def change
    create_table :lead_sources do |t|
      t.string :name
      t.timestamps
    end
  end
end
