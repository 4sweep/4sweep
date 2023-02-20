class AddCommentToFlags < ActiveRecord::Migration[4.2]
  def change
    add_column :flags, :comment, :string
  end
end
