class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.string :file
      t.references :athlete

      t.timestamps
    end
    add_index :documents, :athlete_id
  end
end
