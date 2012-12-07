class RemoveAthleteIdFromEvents < ActiveRecord::Migration
  def up
    remove_column :events, :athlete_id
  end

  def down
    add_column :events, :athlete_id, :integer
  end
end
