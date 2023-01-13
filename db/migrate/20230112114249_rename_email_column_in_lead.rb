class RenameEmailColumnInLead < ActiveRecord::Migration[6.0]
  def change
    rename_column :leads, :email_id, :email
  end
end
