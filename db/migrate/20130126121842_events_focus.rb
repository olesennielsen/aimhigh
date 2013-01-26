class EventsFocus < ActiveRecord::Migration
  def up
    create_table 'events_focus_areas', :id => false do |t|
        t.column :event_id, :integer
        t.column :focus_area_id, :integer
      end
  end

  def down
  end
end
