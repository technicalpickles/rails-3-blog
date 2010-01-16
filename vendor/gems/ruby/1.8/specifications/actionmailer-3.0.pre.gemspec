# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{actionmailer}
  s.version = "3.0.pre"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = ["David Heinemeier Hansson"]
  s.autorequire = %q{action_mailer}
  s.date = %q{2010-01-15}
  s.description = %q{Makes it trivial to test and deliver emails sent from a single service layer.}
  s.email = %q{david@loudthinking.com}
  s.files = ["README", "lib/tasks"]
  s.homepage = %q{http://www.rubyonrails.org}
  s.require_paths = ["lib"]
  s.requirements = ["none"]
  s.rubyforge_project = %q{actionmailer}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Service layer for easy email delivery and testing.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<actionpack>, ["= 3.0.pre"])
      s.add_runtime_dependency(%q<mail>, ["~> 1.6.0"])
    else
      s.add_dependency(%q<actionpack>, ["= 3.0.pre"])
      s.add_dependency(%q<mail>, ["~> 1.6.0"])
    end
  else
    s.add_dependency(%q<actionpack>, ["= 3.0.pre"])
    s.add_dependency(%q<mail>, ["~> 1.6.0"])
  end
end
