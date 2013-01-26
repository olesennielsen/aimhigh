class CreateFocus < ActiveRecord::Migration
  def change
    create_table :focus_areas do |t|
      t.string :code
      t.string :name

      t.timestamps
    end
  end
end
