class ChangeCompanyTypeColumnInLead < ActiveRecord::Migration[6.0]
  change_table :leads do |t|
    t.change :company_id, :integer
  end
end
