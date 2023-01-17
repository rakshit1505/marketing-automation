class CreateAudits < ActiveRecord::Migration[6.0]
  def change
    create_table :audits do |t|

      t.timestamps
    end
  end
end
