class AddSubmittedToFlag < ActiveRecord::Migration[4.2]
  def change
    add_column :flags, :submitted_at, :timestamp
  end
end
