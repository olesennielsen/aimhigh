class RemoveFirstNameAndLastNameFromAthletes < ActiveRecord::Migration
  def up
    remove_column :athletes, :firstname
    remove_column :athletes, :lastname
  end

  def down
    add_column :athletes, :lastname, :string
    add_column :athletes, :firstname, :string
  end
end
