module TrafficSpy
  class DbLoader

    attr_reader :ruby_params, :identifier

    def initialize(ruby_params = {}, identifier = "")
      @ruby_params = ruby_params
      @identifier = identifier
    end

    def loadable_params
      payload_params = ruby_params.select{|k,v| payload_columns.include?(k)}
      url_params = ruby_params.select{|k,v| url_columns.include?(k)}
      payload_params.merge({"url" => Url.find_or_create_by(url_params)})
    end

    def load_databases
      user = User.find_by(identifier: identifier)
      user.payloads.create(loadable_params)
    end

    def payload_columns
      TrafficSpy::Payload.columns.map { |x| x.name }
    end

    def url_columns
      TrafficSpy::Url.columns.map {|x| x.name}
    end
  end
end
