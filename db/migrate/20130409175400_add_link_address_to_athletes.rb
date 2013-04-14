class AddLinkAddressToAthletes < ActiveRecord::Migration
  def change
    add_column :athletes, :link_address, :string
  end
end
