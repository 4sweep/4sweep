class AddLastCheckedToFlags < ActiveRecord::Migration
  def change
    add_column :flags, :last_checked, :timestamp
  end
end
