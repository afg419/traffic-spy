ActiveRecord::Schema.define(version: 20151208213512) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "payloads", force: :cascade do |t|
    t.string  "url"
    t.string  "requested_at"
    t.integer "responded_in"
    t.string  "referred_by"
    t.string  "request_type"
    t.string  "event_name"
    t.integer "resolution_width"
    t.integer "resolution_height"
    t.string  "ip"
    t.string  "browser"
    t.string  "platform"
    t.integer "user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "identifier"
    t.string "root_url"
  end

end
