class AddFirstnameToAthletes < ActiveRecord::Migration
  def change
    add_column :athletes, :firstname, :string
  end
end
