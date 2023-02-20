class AddEditsToFlags < ActiveRecord::Migration[4.2]
  def change
    add_column :flags, :edits, :text
  end
end
