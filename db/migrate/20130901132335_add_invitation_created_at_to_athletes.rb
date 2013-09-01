class AddInvitationCreatedAtToAthletes < ActiveRecord::Migration
  def change
    add_column :athletes, :invitation_created_at, :datetime
  end
end
