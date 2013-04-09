class AddLinkUsernameToAthletes < ActiveRecord::Migration
  def change
    add_column :athletes, :link_username, :string
  end
end
