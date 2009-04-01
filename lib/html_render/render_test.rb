require 'html_render/images'
require 'html_render/render_batches'

module HTMLRender; end
module HTMLRender::RenderTest
  # Result of a RenderTest::run() call
  class Result
    # The portion of a result specific to an individual server
    class ServerResult
      attr_reader :server, :expected, :actual

      # Initializes the ServerResult.
      #
      # Params:
      #   server: name of the server
      #   expected: Image we expected
      #   actual: Image we got
      def initialize(server, expected, actual)
        @server = server
        @expected = expected
        @actual = actual
      end

      def pass?
        actual == expected
      end

      def difference
        expected.difference(actual)
      end
    end

    def servers
      raise NotImplementedError
    end

    # Returns the ServerResult corresponding to the given Server
    def details_for(server)
      raise NotImplementedError
    end

    def pass?
      @pass ||= servers.select{|s| !details_for(s).pass?}.empty?
    end
  end

  class DirectoryResult < Result
    attr_reader :path
    attr_reader :valid_path
    attr_reader :canonical_path

    def initialize(path, valid_path, canonical_path)
      @path = path
      @valid_path = valid_path
      @canonical_path = canonical_path
    end

    def servers
      @servers ||= Dir.glob(File.join(path, '*.png')).collect{ |s| s.split(/\//).last[0..-5] }.sort
    end

    def details_for(server)
      @details_for ||= {}
      @details_for[server] ||= ServerResult.new(
        server,
        expected_png_for(server),
        actual_png_for(server)
      )
    end

    private

    # Returns the PNG we actually got for the given server name
    def actual_png_for(server)
      @actual_png_for ||= {}
      @actual_png_for[server] ||= begin
        filename = filename_of_actual_png_for(server)
        File.open(filename) do |f|
          HTMLRender::Images::PNGImage.new(f.read)
        end
      end
    end

    # Returns the PNG expected of the given server name, or nil
    def expected_png_for(server)
      @expected_png_for ||= {}
      @expected_png_for[server] ||= begin
        filename = filename_of_expected_png_for(server)
        if filename
          File.open(filename) do |f|
            HTMLRender::Images::PNGImage.new(f.read)
          end
        end
      end
    end

    def filename_of_actual_png_for(server)
      # Assume it exists--otherwise, "servers" wouldn't return it
      File.join(path, "#{server}.png")
    end

    # Returns the path to the expected PNG for the given server name, or nil
    def filename_of_expected_png_for(server)
      specific = File.join(valid_path, "#{server}.png")

      @filename_of_expected_png_for ||= {}
      @filename_of_expected_png_for[server] ||= case
        when File.exist?(specific) then specific
        when File.exist?(canonical_path) then canonical_path
        else nil
      end
    end
  end

  # Tests, across browsers, that some HTML renders correctly.
  #
  # A DirectoryRenderTest works within a particular directory in the
  # filesystem, and it expects the following files:
  #
  # - html.html
  # - canonical.png (what we want it to look like)
  # - valid/SERVER.png for each SYSTEM (i.e., "ff3", "winxp-ie6", etc.)
  # - runs/20080331014523/SERVER.png (at the time "run" was called)
  #
  # Calling run() with a hash of servers (see
  # HtmlRender::RenderBatches::HTTPRenderBatch) will batch-render for each
  # server, potentially throwing a
  # HtmlRender::Renderers::HTTPRenderer::ServerError if the render fails.
  # It will return an HtmlRender::RenderTest::Result.
  class DirectoryRenderTest
    attr_reader :path

    def initialize(path)
      @path = path
    end

    def html
      @html ||= File.open(html_path) do |f|
        f.read
      end
    end

    def run(servers_hash)
      run_path = create_new_run_path!

      begin
        batch = HTMLRender::RenderBatches::HTTPRenderBatch.new(servers_hash)
        batch.render_html_to_directory(html, create_new_run_path!)
      rescue Exception => e
        FileUtils.rm_r(run_path)
        throw e
      end

      DirectoryResult.new(run_path, valid_path, canonical_path)
    end

    # Returns the results of the last test. If the "valid" results changed
    # since the last time run() was called, then last_result.pass? may
    # return a different value than before (since it will compare the
    # previously-generated actual .png's with the newer expected .png's).
    def last_result
      DirectoryResult.new(last_run_path, valid_path, canonical_path)
    end

    private

    def html_path
      File.join(path, 'html.html')
    end

    def last_run_path
      runs_path = File.join(path, 'runs', '??????????????')
      Dir.glob(runs_path).sort.last
    end

    def create_new_run_path!
      path = new_run_path
      FileUtils.mkdir_p(path)
      path
    end

    def canonical_path
      @canoncial_path ||= File.join(path, 'canonical.png')
    end

    def valid_path
      @valid_path ||= File.join(path, 'valid')
    end

    def new_run_path
      File.join(path, 'runs', current_timestamp_string)
    end

    def current_timestamp_string
      Time.now.utc.strftime('%Y%m%d%H%M%S')
    end
  end
end
