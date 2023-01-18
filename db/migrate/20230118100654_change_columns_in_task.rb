class ChangeColumnsInTask < ActiveRecord::Migration[6.0]
  def change
    remove_column :tasks, :last_name
    add_column :tasks, :repeat, :boolean
    add_column :tasks, :reminder, :boolean
    add_column :tasks, :subject, :string
  end
end
