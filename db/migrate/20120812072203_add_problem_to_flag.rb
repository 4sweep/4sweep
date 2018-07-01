class AddProblemToFlag < ActiveRecord::Migration
  def change
    add_column :flags, :problem, :string
  end
end
