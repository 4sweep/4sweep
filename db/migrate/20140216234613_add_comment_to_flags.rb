class AddCommentToFlags < ActiveRecord::Migration
  def change
    add_column :flags, :comment, :string
  end
end
