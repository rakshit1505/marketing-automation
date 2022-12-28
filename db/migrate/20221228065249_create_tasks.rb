class CreateTasks < ActiveRecord::Migration[6.0]
  def change
    create_table :tasks do |t|
      t.integer :task_owner
      t.string :last_name
      t.string :due_date_time
      t.integer :priority
      t.integer :integer
      t.timestamps
    end
  end
end
