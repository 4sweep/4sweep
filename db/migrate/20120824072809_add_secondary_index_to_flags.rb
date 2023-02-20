class AddSecondaryIndexToFlags < ActiveRecord::Migration[4.2]
  def change
    add_index :flags, :secondaryVenueId
  end
end
