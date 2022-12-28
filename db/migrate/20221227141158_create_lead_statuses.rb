class CreateLeadStatuses < ActiveRecord::Migration[6.0]
  def change
    create_table :lead_statuses do |t|
      t.string :name
      t.timestamps
    end
  end
end
