class CreateUrls < ActiveRecord::Migration
  def change
    create_table :urls do |t|
      t.string :url
      t.integer :responded_in
      t.string :referred_by
      t.string :request_type
      t.string :browser
      t.string :platform
    end
  end
end
