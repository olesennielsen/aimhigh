class AddStatusToAthletes < ActiveRecord::Migration
  def change
    add_column :athletes, :status, :boolean, :default => true
  end
end
