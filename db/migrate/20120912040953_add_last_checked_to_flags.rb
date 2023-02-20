class AddLastCheckedToFlags < ActiveRecord::Migration[4.2]
  def change
    add_column :flags, :last_checked, :timestamp
  end
end
