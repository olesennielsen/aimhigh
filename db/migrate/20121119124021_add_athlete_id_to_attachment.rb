class AddAthleteIdToAttachment < ActiveRecord::Migration
  def change
    add_column :attachments, :athlete_id, :integer
  end
end
