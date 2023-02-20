class AddHiddenToFlags < ActiveRecord::Migration[4.2]
  def change
    add_column :flags, :hidden, :boolean, :null => false, :default => false
  end
end
