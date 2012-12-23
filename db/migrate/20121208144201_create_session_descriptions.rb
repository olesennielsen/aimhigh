class CreateSessionDescriptions < ActiveRecord::Migration
  def change
    create_table :session_descriptions do |t|
      t.string :name
      t.integer :time
      t.string :description

      t.timestamps
    end
  end
end
