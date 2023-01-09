class AddUserInLead < ActiveRecord::Migration[6.0]
  def change
    add_reference :leads, :user, foreign_key: true, index: true
  end
end
