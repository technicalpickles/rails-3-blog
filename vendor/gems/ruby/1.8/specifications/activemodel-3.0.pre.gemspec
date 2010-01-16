# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{activemodel}
  s.version = "3.0.pre"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = ["David Heinemeier Hansson"]
  s.date = %q{2010-01-15}
  s.description = %q{Extracts common modeling concerns from ActiveRecord to share between similar frameworks like ActiveResource.}
  s.email = %q{david@loudthinking.com}
  s.files = ["README", "lib/tasks"]
  s.homepage = %q{http://www.rubyonrails.org}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{activemodel}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{A toolkit for building other modeling frameworks like ActiveRecord}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, ["= 3.0.pre"])
    else
      s.add_dependency(%q<activesupport>, ["= 3.0.pre"])
    end
  else
    s.add_dependency(%q<activesupport>, ["= 3.0.pre"])
  end
end
