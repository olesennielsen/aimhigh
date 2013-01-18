class AddLastnameToAthletes < ActiveRecord::Migration
  def change
    add_column :athletes, :lastname, :string
  end
end
