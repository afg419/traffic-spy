class AddColumnPayloadSha < ActiveRecord::Migration
  def change
    add_column :payloads, :payload_sha, :string
  end
end
