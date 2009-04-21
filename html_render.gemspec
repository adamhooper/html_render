# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{html_render}
  s.version = "0.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Adam Hooper"]
  s.date = %q{2009-04-20}
  s.description = %q{Make images from HTML strings}
  s.email = %q{adam@adamhooper.com}
  s.extra_rdoc_files = ["README.rdoc", "lib/html_render.rb", "lib/html_render/render_batches.rb", "lib/html_render/renderers.rb", "lib/html_render/images.rb", "lib/html_render/render_test.rb", "lib/html_render/render_test/rails.rb"]
  s.files = ["README.rdoc", "Rakefile", "html_render.gemspec", "lib/html_render.rb", "lib/html_render/render_batches.rb", "lib/html_render/renderers.rb", "lib/html_render/images.rb", "lib/html_render/render_test.rb", "lib/html_render/render_test/rails.rb", "Manifest"]
  s.has_rdoc = true
  s.homepage = %q{http://adamhooper.com/eng}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Html_render", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{html_render}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Make images from HTML strings}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<httpclient>, [">= 2.1.4"])
      s.add_runtime_dependency(%q<rmagick>, [">= 2.9.1"])
    else
      s.add_dependency(%q<httpclient>, [">= 2.1.4"])
      s.add_dependency(%q<rmagick>, [">= 2.9.1"])
    end
  else
    s.add_dependency(%q<httpclient>, [">= 2.1.4"])
    s.add_dependency(%q<rmagick>, [">= 2.9.1"])
  end
end
