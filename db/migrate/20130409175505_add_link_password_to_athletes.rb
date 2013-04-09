class AddLinkPasswordToAthletes < ActiveRecord::Migration
  def change
    add_column :athletes, :link_password, :string
  end
end
