class RemoveColumnFromPayloads < ActiveRecord::Migration
  def change
    remove_column :payloads, :url
    remove_column :payloads, :responded_in
    remove_column :payloads, :referred_by
    remove_column :payloads, :request_type
    remove_column :payloads, :browser
    remove_column :payloads, :platform
    add_column :payloads, :url_id, :integer
  end
end


# t.string :url
# t.integer :responded_in
# t.string :referred_by
# t.string :request_type
# t.string :browser
# t.string :platform
