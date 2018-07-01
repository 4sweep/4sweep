class AddStatusIndexToFlags < ActiveRecord::Migration
  def change
    add_index :flags, :status
  end
end
