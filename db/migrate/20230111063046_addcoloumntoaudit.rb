class Addcoloumntoaudit < ActiveRecord::Migration[6.0]
  def change
    add_column :audits, :field_name , :string
    add_reference :audits,  :user, foreign_key: true, index: true
  end
end
