class AddSubmittedToFlag < ActiveRecord::Migration
  def change
    add_column :flags, :submitted_at, :timestamp
  end
end
