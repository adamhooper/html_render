require 'html_render/renderers'

module HTMLRender; end
module HTMLRender::RenderBatches
  class HTTPRenderBatch
    attr_reader :servers

    # +servers+: Hash of (String) key to (String) URL to pass to
    #            HTTPRenderer
    def initialize(servers)
      @servers = servers
    end

    # +html+: HTML to render
    # +directory+: Directory in which to dump PNG files (one per server)
    def render_html_to_directory(html, directory)
      threads = create_threads(html, directory)
      threads.each { |t| t.join }
    end

    private

    def create_threads(html, dir)
      threads = []

      servers.each do |key, url|
        threads << create_thread(html, url, File.join(dir, "#{key}.png"))
      end

      threads
    end

    def create_thread(html, url, filename)
      Thread.new(html, url, filename) do |html, url, filename|
        renderer = HTMLRender::Renderers::HTTPRenderer.new(url)
        image = renderer.render(html)
        File.open(filename, 'w') do |f|
          f.write(image.to_blob)
        end
      end
    end
  end
end
