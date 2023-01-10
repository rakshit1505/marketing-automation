class AddPolymorphicColumnsInNote < ActiveRecord::Migration[6.0]
  def change
    add_reference :notes, :notable, polymorphic: true
  end
end
