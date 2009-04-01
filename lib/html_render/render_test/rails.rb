require 'action_controller/test_process'
require 'action_view/test_case'

require 'html_render/render_test'

module HTMLRender; end
module HTMLRender::RenderTest; end

module HTMLRender::RenderTest::Rails
  class RenderTest < HTMLRender::RenderTest::DirectoryRenderTest
    def initialize(*args, &block)
      super(*args, &block)
    end

    def run(*args, &block)
      write_html_to_run_directory
      super(*args, &block)
    end

    def html
      @html ||= wrap_html { view.render(render_options) }
    end

    def render_options
      {
        template_type => template_path,
        :locals => locals
      }
    end

    def template_type
      :partial
    end

    def assigns
      {}
    end

    def locals
      {}
    end

    # Wraps the rendered HTML to create a fully-valid XHTML 1.0 page which
    # may be rendered.
    #
    # Override the +css+ or +javascript+ methods to include CSS or
    # JavaScript in the output. (Most Rails project testing frameworks will
    # rely upon a subclass of this RenderTest with css returning the
    # project's entire CSS library.)
    def wrap_html
      <<-EOT
      <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
      <html xmlns='http://www.w3.org/1999/xhtml'>
        <head>
          <title>Test</title>
          <style type="text/css">
            #{css}
          </style>
          <script type="text/javascript">
            #{javascript}
          </script>
        </head>
        <body>
          #{yield}
        </body>
      </html>
      EOT
    end

    def css
      ""
    end

    def javascript
      ""
    end

    private

    def controller
      returning(ActionView::TestCase::TestController.new) do |controller|
        # Set @url so url_for() doesn't crash
        request = controller.instance_variable_get(:@request)
        controller.instance_variable_set(:@url, ActionController::UrlRewriter.new(request, {}))
      end
    end

    def view
      ActionView::Base.new(ActionController::Base.view_paths, assigns, controller)
    end

    def write_html_to_run_directory
      last_run_html_file = File.join(run_path, 'html.html')
      File.open(last_run_html_file, 'w') do |f|
        f.write(html)
      end
    end
  end
end
