class AddHiddenToFlags < ActiveRecord::Migration
  def change
    add_column :flags, :hidden, :boolean, :null => false, :default => false
  end
end
