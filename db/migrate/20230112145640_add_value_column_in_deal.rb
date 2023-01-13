class AddValueColumnInDeal < ActiveRecord::Migration[6.0]
  def change
    add_column :deals, :value, :float
  end
end
