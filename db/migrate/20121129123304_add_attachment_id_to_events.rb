class AddAttachmentIdToEvents < ActiveRecord::Migration
  def change
    add_column :events, :attachment_id, :integer
  end
end
