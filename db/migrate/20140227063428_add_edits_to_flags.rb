class AddEditsToFlags < ActiveRecord::Migration
  def change
    add_column :flags, :edits, :text
  end
end
