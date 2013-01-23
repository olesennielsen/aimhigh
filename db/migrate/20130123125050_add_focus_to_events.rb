class AddFocusToEvents < ActiveRecord::Migration
  def change
    add_column :events, :focus, :string
  end
end
