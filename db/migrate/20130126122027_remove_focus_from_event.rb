class RemoveFocusFromEvent < ActiveRecord::Migration
  def up
    remove_column :events, :focus
  end

  def down
    add_column :events, :focus, :string
  end
end
