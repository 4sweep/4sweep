class AddScheduledToFlags < ActiveRecord::Migration
  def change
    add_column :flags, :scheduled_at, :datetime
  end
end
