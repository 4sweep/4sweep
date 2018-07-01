class SetDefaultStatusOnFlag < ActiveRecord::Migration
  def up
    change_column :flags, :status, :string, :default => 'new'
  end

  def down
    # You can't currently remove default values in Rails
    raise ActiveRecord::IrreversibleMigration, "Can't remove the default"
  end
end
