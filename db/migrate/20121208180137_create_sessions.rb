class CreateSessions < ActiveRecord::Migration
  def change
    create_table :sessions do |t|
      t.string :title
      t.string :description
      t.string :focus

      t.timestamps
    end
  end
end
