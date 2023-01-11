class Removecolumnfromlead < ActiveRecord::Migration[6.0]
  def change
    remove_column :leads, :name_check, :boolean
    remove_column :leads, :email_check, :boolean
    remove_column :leads, :phone_check, :boolean
    remove_column :leads, :lead_source_check, :boolean
    remove_column :leads, :company_check, :boolean
    remove_column :leads, :sales_owner_check, :boolean
    end
end
