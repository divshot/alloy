module Alloy
  class Throttle < Rack::Throttle::Hourly
    def allowed?(request)
      return true unless request.path.match(/\A\/compile/)
      super
    end

    def rate_limit_exceeded
      $redis.incrby "stats:rate_limits", 1
      super
    end

    # This is here to patch an error in the gem, not to add custom
    # functionality.
    def http_error(code, message = nil, headers = {})
      [code, {'Content-Type' => 'text/plain; charset=utf-8'}.merge(headers),
        [http_status(code) + (message.nil? ? "\n" : " (#{message})\n")]]
    end
  end
end