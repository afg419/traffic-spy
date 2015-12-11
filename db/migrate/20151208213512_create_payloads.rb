class CreatePayloads < ActiveRecord::Migration
  def change
    create_table :payloads do |t|
      t.string  :url
      t.string  :requested_at
      t.integer :responded_in
      t.string  :referred_by
      t.string  :request_type
      t.string  :event_name
      t.integer :resolution_width
      t.integer :resolution_height
      t.string  :ip
      t.string  :browser
      t.string  :platform
      t.integer :user_id
    end
  end
end
