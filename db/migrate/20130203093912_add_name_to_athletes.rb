class AddNameToAthletes < ActiveRecord::Migration
  def change
    add_column :athletes, :name, :string
  end
end
