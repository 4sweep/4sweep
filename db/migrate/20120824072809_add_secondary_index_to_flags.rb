class AddSecondaryIndexToFlags < ActiveRecord::Migration
  def change
    add_index :flags, :secondaryVenueId
  end
end
