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
    attr_accessor :url

    def initialize(url)
      @url = url
    end

    def render(html)
      client = HTTPClient.new

      response = client.post(url, html)
      if response.status != 200
        raise Exception.new("Unexpected HTTP server response from #{url}: #{response.inspect}")
      end

      HTMLRender::Images::PNGImage.new(response.content)
    end
  end
end
