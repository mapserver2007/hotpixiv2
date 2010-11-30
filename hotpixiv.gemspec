# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{hotpixiv}
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["mapserver2007"]
  s.date = %q{2010-11-30}
  s.default_executable = %q{hotpixiv}
  s.description = %q{hotpixiv. Auto collection tool in pixiv.}
  s.email = %q{mapserver2007@gmail.com}
  s.executables = ["hotpixiv"]
  s.extra_rdoc_files = ["README.rdoc", "ChangeLog"]
  s.files = ["README.rdoc", "ChangeLog", "Rakefile", "bin/hotpixiv", "lib/hotpixiv", "lib/hotpixiv/download.rb", "lib/hotpixiv/runner.rb", "lib/hotpixiv/utils.rb", "lib/hotpixiv.rb", "spec/hotpixiv_helper.rb", "spec/hotpixiv_spec.rb"]
  s.homepage = %q{http://github.com/mapserver2007/hotpixiv2}
  s.rdoc_options = ["--title", "hotpixiv documentation", "--charset", "utf-8", "--opname", "index.html", "--line-numbers", "--main", "README.rdoc", "--inline-source", "--exclude", "^(examples|extras)/"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{hotpixiv2}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{hotpixiv. Auto collection tool in pixiv.}
  s.test_files = ["spec/hotpixiv_helper.rb", "spec/hotpixiv_spec.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
