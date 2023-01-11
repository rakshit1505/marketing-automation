class Addcolumntoaudit < ActiveRecord::Migration[6.0]
  def change
        add_column :audits, :description, :string
  end
end
