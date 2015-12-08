class CreatePayloads < ActiveRecord::Migration
  def change
    create_table :payloads do |t|
      t.string  :url
      t.string  :requestedAt
      t.integer :respondedIn
      t.string  :referredBy
      t.string  :requestType
      t.string  :eventName
      t.integer :resolutionWidth
      t.integer :resolutionHeight
      t.string  :ip
      t.string  :browser
      t.string  :platform
      t.integer :user_id
    end
  end
end

# {"url"=>"http://jumpstartlab.com/blog",
#            "requestedAt"=>"2013-02-16 21:38:28 -0700",
#            "respondedIn"=>37,
#            "referredBy"=>"http://jumpstartlab.com",
#            "requestType"=>"GET",
#            "parameters"=>[],
#            "eventName"=>"socialLogin",
#            "resolutionWidth"=>"1920",
#            "resolutionHeight"=>"1280",
#            "ip"=>"63.29.38.211",
#            "browser"=>"Chrome",
#            "platform"=>"Macintosh",
#            "identifier"=>"jumpstartlab",
#            "rootUrl"=>"jumpstartlab.com"}
