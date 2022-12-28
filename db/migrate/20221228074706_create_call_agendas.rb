class CreateCallAgendas < ActiveRecord::Migration[6.0]
  def change
    create_table :call_agendas do |t|
      t.string :objective
      t.string :description
      t.integer :call_information_id
      t.timestamps
    end
  end
end
