class CreateMeetings < ActiveRecord::Migration[6.0]
  def change
    create_table :meetings do |t|
      t.string :title
      t.integer :type_of_meeting
      t.boolean :is_online
      t.string :duration
      t.integer :user_id
      t.string :description
      t.string :reminder
      t.string :agenda
      t.string :status
      t.timestamps
    end
  end
end
