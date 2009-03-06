Gem::Specification.new do |s|
  s.name = %q{html_render}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Adam Hooper"]
  s.date = %q{2009-03-06}
  s.description = %q{Make images from HTML strings}
  s.email = %q{adam@adamhooper.com}
  s.extra_rdoc_files = ["README.rdoc", "lib/html_render.rb", "lib/html_render/renderers.rb", "lib/html_render/images.rb"]
  s.files = ["README.rdoc", "Rakefile", "lib/html_render.rb", "lib/html_render/renderers.rb", "lib/html_render/images.rb", "Manifest", "html_render.gemspec"]
  s.has_rdoc = true
  s.homepage = %q{http://adamhooper.com/eng}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Html_render", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{html_render}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{Make images from HTML strings}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_runtime_dependency(%q<httpclient>, [">= 2.1.4"])
      s.add_runtime_dependency(%q<rmagick>, [">= 2.9.1"])
      s.add_development_dependency(%q<echoe>, [">= 0"])
    else
      s.add_dependency(%q<httpclient>, [">= 2.1.4"])
      s.add_dependency(%q<rmagick>, [">= 2.9.1"])
      s.add_dependency(%q<echoe>, [">= 0"])
    end
  else
    s.add_dependency(%q<httpclient>, [">= 2.1.4"])
    s.add_dependency(%q<rmagick>, [">= 2.9.1"])
    s.add_dependency(%q<echoe>, [">= 0"])
  end
end
