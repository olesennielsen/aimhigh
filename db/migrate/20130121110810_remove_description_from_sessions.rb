class RemoveDescriptionFromSessions < ActiveRecord::Migration
  def up
    remove_column :sessions, :description
  end

  def down
    add_column :sessions, :description, :string
  end
end
