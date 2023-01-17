class AddColumntoLead < ActiveRecord::Migration[6.0]
  def change
    add_column :leads, :name_check, :boolean, :default => true
    add_column :leads, :email_check, :boolean, :default => true
    add_column :leads, :phone_check, :boolean, :default => true
    add_column :leads, :lead_source_check, :boolean, :default => true
    add_column :leads, :company_check, :boolean, :default => true
    add_column :leads, :sales_owner_check, :boolean, :default => true
  end
end
