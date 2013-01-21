class AddSessionDescriptionIdToSessions < ActiveRecord::Migration
  def change
    add_column :sessions, :session_description_id, :int
  end
end
