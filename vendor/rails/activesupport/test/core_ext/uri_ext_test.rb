require 'abstract_unit'
require 'uri'
require 'active_support/core_ext/uri'

class URIExtTest < Test::Unit::TestCase
  def test_uri_decode_handle_multibyte
    str = "\xE6\x97\xA5\xE6\x9C\xAC\xE8\xAA\x9E" # Ni-ho-nn-go in UTF-8, means Japanese.
    str.force_encoding(Encoding::UTF_8) if str.respond_to?(:force_encoding)

    if URI.const_defined?(:Parser)
      parser = URI::Parser.new
      assert_equal str, parser.unescape(parser.escape(str))
    else
      assert_equal str, URI.unescape(URI.escape(str))
    end
  end
end
