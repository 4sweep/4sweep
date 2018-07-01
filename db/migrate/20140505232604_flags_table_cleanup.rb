class FlagsTableCleanup < ActiveRecord::Migration
  def up
    remove_column :flags, :primaryHasHome
    remove_column :flags, :secondaryHasHome
    remove_column :flags, :hidden
  end

  def down
  end
end
