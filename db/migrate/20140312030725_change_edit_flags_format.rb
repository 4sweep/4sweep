class ChangeEditFlagsFormat < ActiveRecord::Migration[4.2]
  def up
    EditVenueFlag.all.each do |flag|
      newvalues = flag.edits 
      flag.edits = {'oldvalues' => newvalues, 'newvalues' => newvalues}
      if flag.status != 'resolved'
        flag.status = "alternate resolution"
        flag.resolved_details = "(beta legacy)"
      end
      flag.save
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
