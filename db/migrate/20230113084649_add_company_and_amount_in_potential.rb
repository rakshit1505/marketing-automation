class AddCompanyAndAmountInPotential < ActiveRecord::Migration[6.0]
  def change
    add_reference :potentials, :company, foreign_key: true, index: true
    add_column :potentials, :amount, :float
  end
end
