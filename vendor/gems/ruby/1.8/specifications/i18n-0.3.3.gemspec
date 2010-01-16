# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{i18n}
  s.version = "0.3.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Sven Fuchs", "Joshua Harvey", "Matt Aimonetti", "Stephan Soller", "Saimon Moore"]
  s.date = %q{2009-12-28}
  s.description = %q{Add Internationalization support to your Ruby application.}
  s.email = %q{rails-i18n@googlegroups.com}
  s.extra_rdoc_files = ["README.textile"]
  s.files = ["CHANGELOG.textile", "MIT-LICENSE", "README.textile", "Rakefile", "lib/i18n.rb", "lib/i18n/backend.rb", "lib/i18n/backend/active_record.rb", "lib/i18n/backend/active_record/missing.rb", "lib/i18n/backend/active_record/store_procs.rb", "lib/i18n/backend/active_record/translation.rb", "lib/i18n/backend/base.rb", "lib/i18n/backend/cache.rb", "lib/i18n/backend/cascade.rb", "lib/i18n/backend/chain.rb", "lib/i18n/backend/fallbacks.rb", "lib/i18n/backend/fast.rb", "lib/i18n/backend/gettext.rb", "lib/i18n/backend/helpers.rb", "lib/i18n/backend/interpolation_compiler.rb", "lib/i18n/backend/metadata.rb", "lib/i18n/backend/pluralization.rb", "lib/i18n/backend/simple.rb", "lib/i18n/core_ext/object/meta_class.rb", "lib/i18n/core_ext/string/interpolate.rb", "lib/i18n/exceptions.rb", "lib/i18n/gettext.rb", "lib/i18n/helpers.rb", "lib/i18n/helpers/gettext.rb", "lib/i18n/locale.rb", "lib/i18n/locale/fallbacks.rb", "lib/i18n/locale/tag.rb", "lib/i18n/locale/tag/parents.rb", "lib/i18n/locale/tag/rfc4646.rb", "lib/i18n/locale/tag/simple.rb", "lib/i18n/version.rb", "test/all.rb", "test/api/basics.rb", "test/api/defaults.rb", "test/api/interpolation.rb", "test/api/link.rb", "test/api/localization/date.rb", "test/api/localization/date_time.rb", "test/api/localization/procs.rb", "test/api/localization/time.rb", "test/api/lookup.rb", "test/api/pluralization.rb", "test/api/procs.rb", "test/cases/api/active_record_test.rb", "test/cases/api/all_features_test.rb", "test/cases/api/cascade_test.rb", "test/cases/api/chain_test.rb", "test/cases/api/fallbacks_test.rb", "test/cases/api/fast_test.rb", "test/cases/api/pluralization_test.rb", "test/cases/api/simple_test.rb", "test/cases/backend/active_record/missing_test.rb", "test/cases/backend/active_record_test.rb", "test/cases/backend/cache_test.rb", "test/cases/backend/cascade_test.rb", "test/cases/backend/chain_test.rb", "test/cases/backend/fallbacks_test.rb", "test/cases/backend/fast_test.rb", "test/cases/backend/helpers_test.rb", "test/cases/backend/interpolation_compiler_test.rb", "test/cases/backend/metadata_test.rb", "test/cases/backend/pluralization_test.rb", "test/cases/backend/simple_test.rb", "test/cases/core_ext/string/interpolate_test.rb", "test/cases/gettext/api_test.rb", "test/cases/gettext/backend_test.rb", "test/cases/i18n_exceptions_test.rb", "test/cases/i18n_load_path_test.rb", "test/cases/i18n_test.rb", "test/cases/locale/fallbacks_test.rb", "test/cases/locale/tag/rfc4646_test.rb", "test/cases/locale/tag/simple_test.rb", "test/fixtures/locales/de.po", "test/fixtures/locales/en.rb", "test/fixtures/locales/en.yml", "test/fixtures/locales/plurals.rb", "test/test_helper.rb", "vendor/po_parser.rb"]
  s.homepage = %q{http://rails-i18n.org}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{i18n}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{New wave Internationalization support for Ruby}
  s.test_files = ["test/all.rb", "test/api/basics.rb", "test/api/defaults.rb", "test/api/interpolation.rb", "test/api/link.rb", "test/api/localization/date.rb", "test/api/localization/date_time.rb", "test/api/localization/procs.rb", "test/api/localization/time.rb", "test/api/lookup.rb", "test/api/pluralization.rb", "test/api/procs.rb", "test/cases/api/active_record_test.rb", "test/cases/api/all_features_test.rb", "test/cases/api/cascade_test.rb", "test/cases/api/chain_test.rb", "test/cases/api/fallbacks_test.rb", "test/cases/api/fast_test.rb", "test/cases/api/pluralization_test.rb", "test/cases/api/simple_test.rb", "test/cases/backend/active_record/missing_test.rb", "test/cases/backend/active_record_test.rb", "test/cases/backend/cache_test.rb", "test/cases/backend/cascade_test.rb", "test/cases/backend/chain_test.rb", "test/cases/backend/fallbacks_test.rb", "test/cases/backend/fast_test.rb", "test/cases/backend/helpers_test.rb", "test/cases/backend/interpolation_compiler_test.rb", "test/cases/backend/metadata_test.rb", "test/cases/backend/pluralization_test.rb", "test/cases/backend/simple_test.rb", "test/cases/core_ext/string/interpolate_test.rb", "test/cases/gettext/api_test.rb", "test/cases/gettext/backend_test.rb", "test/cases/i18n_exceptions_test.rb", "test/cases/i18n_load_path_test.rb", "test/cases/i18n_test.rb", "test/cases/locale/fallbacks_test.rb", "test/cases/locale/tag/rfc4646_test.rb", "test/cases/locale/tag/simple_test.rb", "test/fixtures/locales/en.rb", "test/fixtures/locales/plurals.rb", "test/test_helper.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
