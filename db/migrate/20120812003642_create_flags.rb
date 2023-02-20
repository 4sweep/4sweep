class CreateFlags < ActiveRecord::Migration[4.2]
  def change
    create_table :flags do |t|
      t.string :type
      t.string :status
      t.string :venueId
      t.references :user
      t.string :secondaryVenueId
      t.string :primaryName
      t.string :secondaryName
      t.text :primaryJSON
      t.text :secondaryJSON

      t.timestamps
    end
    add_index :flags, :user_id
  end
end
