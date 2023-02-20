class AddProblemToFlag < ActiveRecord::Migration[4.2]
  def change
    add_column :flags, :problem, :string
  end
end
