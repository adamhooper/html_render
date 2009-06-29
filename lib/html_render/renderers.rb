require 'httpclient'

require 'html_render/images'

module HTMLRender; end
module HTMLRender::Renderers
  class Base
    def render(html)
      raise NotImplementedError
    end
  end

  # Renders using an HTTP server built for the very purpose.
  #
  # One should POST the HTML to the given URL, and the server should
  # respond with a PNG image.
  class HTTPRenderer < Base
    class ServerError < Exception; end

    attr_accessor :url

    def initialize(url)
      @url = url
    end

    def render(html)
      client = HTTPClient.new

      begin
        response = client.post(url, html, {
          'Content-Type' => 'application/x-www-form-urlencoded; charset=UTF-8'
        })
      rescue HTTPClient::BadResponseError => e
        raise ServerError.new("Bad response from #{url}: #{e.message}")
      rescue HTTPClient::TimeoutError => e
        raise ServerError.new("Timeout from #{url}: #{e.message}")
      rescue HTTPClient::RetryableResponse => e
        raise ServerError.new("Retryable response from #{url}: #{e.message}")
      rescue HTTPClient::KeepAliveDisconnected => e
        raise ServerError.new("Keep-Alive disconnected from #{url}: #{e.message}")
      end

      if response.status != 200
        raise ServerError.new("Unexpected HTTP server response from #{url}: #{response.inspect}")
      end

      HTMLRender::Images::PNGImage.new(response.content)
    end
  end
end
