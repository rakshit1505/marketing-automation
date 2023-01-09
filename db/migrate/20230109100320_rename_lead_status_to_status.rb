class RenameLeadStatusToStatus < ActiveRecord::Migration[6.0]
  def self.up
    rename_table :lead_statuses, :statuses
    add_column :statuses, :statusable_type, :string
    add_column :statuses, :statusable_id, :integer
  end

  def self.down
    rename_table :statuses, :lead_statuses
    remove_column :statuses, :statusable_type
    remove_column :statuses, :statusable_id
  end
end
