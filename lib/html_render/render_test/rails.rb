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
          <meta http-equiv="Content-type" content="text/html; charset=utf-8" />
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

    protected

    def controller
      returning(ActionView::TestCase::TestController.new) do |controller|
        # Set @url so url_for() doesn't crash
        request = controller.instance_variable_get(:@request)
        controller.instance_variable_set(:@url, ActionController::UrlRewriter.new(request, {}))
      end
    end

    def view
      returning(ActionView::Base.new(ActionController::Base.view_paths, assigns, controller)) do |view|
        view.helpers.send(:include, view.controller.master_helper_module)
      end
    end

    def write_html_to_run_directory
      last_run_html_file = File.join(run_path, 'html.html')
      File.open(last_run_html_file, 'w') do |f|
        f.write(html)
      end
    end
  end

  module Common
    def create_test_case_from_path(relative_path, options)
      clazz = options[:base_class] || RenderTest
      base_path = options[:test_prefix]
      servers = options[:servers]

      test_path = absolute_test_path(relative_path, base_path)
      run_path = absolute_run_path(relative_path, base_path)

      setup_filename = File.join(test_path, 'setup.rb')
      setup_code = File.open(setup_filename) { |f| f.read }

      template_path = File.dirname(relative_path)
      template_dirname = File.dirname(template_path)
      template_basename = File.basename(template_path)
      rails_template_basename = template_basename.sub(/^_/, '')
      rails_template_path = File.join(template_dirname, rails_template_basename)

      FileUtils.mkdir_p(run_path)

      clazz.new(test_path, run_path) do |test_case|
        test_case.instance_eval(<<-EOT, __FILE__, __LINE__)
          def template_path
            #{rails_template_path.inspect}
          end
        EOT

        test_case.instance_eval(setup_code, setup_filename, 1)
      end
    end
    module_function(:create_test_case_from_path)

    private

    def self.absolute_test_path(relative_path, base_path)
      File.join(base_path, relative_path)
    end

    def self.absolute_run_path(relative_path, base_path)
      File.join(absolute_test_path(relative_path, base_path), 'run')
    end
  end

  if defined?(Spec)
    class RenderExampleGroup < Spec::Example::ExampleGroup
      def self.define_example(setup_path, base_path, servers, options)
        relative_path = setup_path[(base_path.length + 1)..-10]
        template_path = File.dirname(relative_path)
        test_key = File.basename(relative_path)

        it 'should render properly' do
          test_case = Common::create_test_case_from_path(relative_path, options.merge(:test_prefix => base_path))
          result = test_case.run(servers)
          result.details.each do |server, detail|
            detail.pass?.should == true
          end
        end
      end

      def self.define_examples(base_path, options)
        servers = options.delete(:servers)

        if !servers || !servers.is_a?(Hash)
          raise ArgumentError.new("options[:servers] must be a hash of :unique_identifier => \"http://path.to.server/which/renders/pngs\"")
        end

        cwd = []
        context_stack = []

        paths = Dir.glob(File.join(base_path, '**', 'setup.rb')).sort.each do |setup_path|
          relative_path = File.dirname(setup_path[(base_path.length + 1)..-1])
          path_parts = relative_path.split('/')

          until relative_path =~ %r%^#{Regexp.quote(cwd.join('/'))}%
            cwd.pop
            context_stack.pop
          end

          until cwd.length == path_parts.length
            cwd.push(path_parts[cwd.length])
            context_stack.push((context_stack.last || self).describe("/#{cwd.join('/')}", :type => :render))
          end

          context_stack.last.define_example(setup_path, base_path, servers, options)
        end
      end
    end
    Spec::Example::ExampleGroupFactory.register(:render, RenderExampleGroup)
  end

  module TestCaseDefinitions
    def define_single_test(setup_path, base_path, servers, options)
      relative_path = setup_path[(base_path.length + 1)..-10]
      template_path = File.dirname(relative_path)
      test_key = File.basename(relative_path)

      self.test("Rendering #{template_path}, case '#{test_key}'") do
        test_case = Common::create_test_case_from_path(relative_path, options.merge(:test_prefix => base_path))
        result = test_case.run(servers)
        result.details.each do |server, detail|
          assert(detail.pass?, "Should render properly on #{server}")
        end
      end
    end

    def define_tests(base_path, options)
      servers = options.delete(:servers)

      if !servers || !servers.is_a?(Hash)
        raise ArgumentError.new("options[:servers] must be a hash of :unique_identifier => \"http://path.to.server/which/renders/pngs\"")
      end

      Dir.glob(File.join(base_path, '**', 'setup.rb')).each do |setup_path|
        self.define_single_test(setup_path, base_path, servers, options)
      end
    end

    private

    def absolute_test_path(relative_path, base_path)
      File.join(base_path, relative_path)
    end

    def absolute_run_path(relative_path, base_path)
      File.join(absolute_test_path(relative_path, base_path), 'run')
    end
  end
end
