class RenameLastNameColumnInCompany < ActiveRecord::Migration[6.0]
  def change
    rename_column :companies, :last_name, :name
  end
end
