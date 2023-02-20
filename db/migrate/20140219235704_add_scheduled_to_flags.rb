class AddScheduledToFlags < ActiveRecord::Migration[4.2]
  def change
    add_column :flags, :scheduled_at, :datetime
  end
end
