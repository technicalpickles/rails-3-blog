# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{actionpack}
  s.version = "3.0.pre"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = ["David Heinemeier Hansson"]
  s.autorequire = %q{action_controller}
  s.date = %q{2010-01-15}
  s.description = %q{Eases web-request routing, handling, and response as a half-way front, half-way page controller. Implemented with specific emphasis on enabling easy unit/integration testing that doesn't require a browser.}
  s.email = %q{david@loudthinking.com}
  s.files = ["README", "lib/tasks"]
  s.homepage = %q{http://www.rubyonrails.org}
  s.require_paths = ["lib"]
  s.requirements = ["none"]
  s.rubyforge_project = %q{actionpack}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Web-flow and rendering framework putting the VC in MVC.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, ["= 3.0.pre"])
      s.add_runtime_dependency(%q<activemodel>, ["= 3.0.pre"])
      s.add_runtime_dependency(%q<rack>, ["~> 1.1.0"])
      s.add_runtime_dependency(%q<rack-test>, ["~> 0.5.0"])
      s.add_runtime_dependency(%q<rack-mount>, ["~> 0.4.0"])
      s.add_runtime_dependency(%q<erubis>, ["~> 2.6.5"])
    else
      s.add_dependency(%q<activesupport>, ["= 3.0.pre"])
      s.add_dependency(%q<activemodel>, ["= 3.0.pre"])
      s.add_dependency(%q<rack>, ["~> 1.1.0"])
      s.add_dependency(%q<rack-test>, ["~> 0.5.0"])
      s.add_dependency(%q<rack-mount>, ["~> 0.4.0"])
      s.add_dependency(%q<erubis>, ["~> 2.6.5"])
    end
  else
    s.add_dependency(%q<activesupport>, ["= 3.0.pre"])
    s.add_dependency(%q<activemodel>, ["= 3.0.pre"])
    s.add_dependency(%q<rack>, ["~> 1.1.0"])
    s.add_dependency(%q<rack-test>, ["~> 0.5.0"])
    s.add_dependency(%q<rack-mount>, ["~> 0.4.0"])
    s.add_dependency(%q<erubis>, ["~> 2.6.5"])
  end
end
