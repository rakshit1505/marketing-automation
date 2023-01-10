class AddColumnsInUser < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :name, :string
    add_column :users, :first_name, :string, limit: 100
    add_index :users, :first_name
    add_column :users, :last_name, :string, limit: 100
    add_index :users, :last_name
  end
end
