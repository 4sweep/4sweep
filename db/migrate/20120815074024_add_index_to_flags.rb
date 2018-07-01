class AddIndexToFlags < ActiveRecord::Migration
  def change
    add_index :flags, :venueId
  end
end
