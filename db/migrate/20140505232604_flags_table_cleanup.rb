class FlagsTableCleanup < ActiveRecord::Migration[4.2]
  def up
    remove_column :flags, :primaryHasHome
    remove_column :flags, :secondaryHasHome
    remove_column :flags, :hidden
  end

  def down
  end
end
