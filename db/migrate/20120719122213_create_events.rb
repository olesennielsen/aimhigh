class CreateEvents < ActiveRecord::Migration
  def self.up
  
    create_table :events do |t|
      t.string :title
	  t.integer :duration
      t.datetime :starts_at
      t.datetime :ends_at
      t.boolean :all_day
      t.text :description
	  t.integer :athlete_id

      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
