class RemoveJsonFieldsFromFlags < ActiveRecord::Migration[4.2]
  def up
    remove_column :flags, :primaryJSON
    remove_column :flags, :secondaryJSON
  end

  def down
    add_column :flags, :secondaryJSON, :text
    add_column :flags, :primaryJSON, :text
  end
end
