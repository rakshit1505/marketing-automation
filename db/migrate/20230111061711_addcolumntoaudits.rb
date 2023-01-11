class Addcolumntoaudits < ActiveRecord::Migration[6.0]
  def change
    add_column :audits, :auditable_type, :string
    add_column :audits, :auditable_id, :integer
  end
end
