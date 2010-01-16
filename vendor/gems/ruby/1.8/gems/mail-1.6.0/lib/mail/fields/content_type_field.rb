# encoding: utf-8
# 
# 
# 
module Mail
  class ContentTypeField < StructuredField
    
    FIELD_NAME = 'content-type'
    CAPITALIZED_FIELD = 'Content-Type'
    
    def initialize(*args)
      if args.last.class == Array
        @main_type = args.last[0]
        @sub_type = args.last[1]
        @parameters = ParameterHash.new.merge!(args.last.last)
        super(CAPITALIZED_FIELD, args.last)
      else
        @main_type = nil
        @sub_type = nil
        @parameters = nil
        super(CAPITALIZED_FIELD, strip_field(FIELD_NAME, args.last))
      end
      self.parse
      self
    end
    
    def parse(val = value)
      unless val.blank?
        self.value = val 
        @element = nil
        element
      end
    end
    
    def element
      begin
        @element ||= Mail::ContentTypeElement.new(value)
      rescue
        attempt_to_clean
      end
    end
    
    def attempt_to_clean
      # Sanitize the value, handle special cases
      @element ||= Mail::ContentTypeElement.new(sanatize(value))
    rescue
      # All else fails, just get the mime type
      @element ||= Mail::ContentTypeElement.new(get_mime_type(value))
    end
    
    def main_type
      @main_type ||= element.main_type
    end

    def sub_type
      @sub_type ||= element.sub_type
    end
    
    def string
      "#{main_type}/#{sub_type}"
    end
    
    def default
      decoded
    end
    
    alias :content_type :string
    
    def parameters
      unless @parameters
        @parameters = ParameterHash.new
        element.parameters.each { |p| @parameters.merge!(p) }
      end
      @parameters
    end

    def ContentTypeField.with_boundary(type)
      new("#{type}; boundary=#{generate_boundary}")
    end
    
    def ContentTypeField.generate_boundary
      "--==_mimepart_#{Mail.random_tag}"
    end

    def value
      if @value.class == Array
        "#{@main_type}/#{@sub_type}; #{stringify(parameters)}"
      else
        @value
      end
    end
    
    def stringify(params)
      params.map { |k,v| "#{k}=#{Encodings.param_encode(v)}" }.join("; ")
    end

    def filename
      case
      when parameters['filename']
        @filename = parameters['filename']
      when parameters['name']
        @filename = parameters['name']
      else 
        @filename = nil
      end
      @filename
    end
    
    # TODO: Fix this up
    def encoded
      "#{CAPITALIZED_FIELD}: #{content_type};\r\n\t#{parameters.encoded};\r\n"
    end
    
    def decoded
      value
    end

    private
    
    def method_missing(name, *args, &block)
      if name.to_s =~ /([\w_]+)=/
        self.parameters[$1] = args.first
        @value = "#{content_type}; #{stringify(parameters)}"
      else
        super
      end
    end
    
    # Various special cases from random emails found that I am not going to change
    # the parser for
    def sanatize( val )
      case
      when val.chomp =~ /^\s*([\w\d\-_]+)\/([\w\d\-_]+)\s*;;+(.*)$/i
        # Handles 'text/plain;; format="flowed"' (double semi colon)
        "#{$1}/#{$2}; #{$3}"
      when val.chomp =~ /^\s*([\w\d\-_]+)\/([\w\d\-_]+)\s*;(ISO[\w\d\-_]+)$/i
        # Microsoft helper:
        # Handles 'mime/type;ISO-8559-1'
        "#{$1}/#{$2}; charset=#{quote_atom($3)}"
      when val.chomp =~ /^text;?$/i
        # Handles 'text;' and 'text'
        "text/plain;"
      when val.chomp =~ /^(\w+);\s(.*)$/i
        # Handles 'text; <parameters>'
        "text/plain; #{$2}"
      when val =~ /([\w\d\-_]+\/[\w\d\-_]+);\scharset="charset="(\w+)""/i
        # Handles text/html; charset="charset="GB2312""
        "#{$1}; charset=#{quote_atom($2)}"
      when val =~ /([\w\d\-_]+\/[\w\d\-_]+);\s+(.*)/i
        type = $1
        # Handles misquoted param values
        # e.g: application/octet-stream; name=archiveshelp1[1].htm
        # and: audio/x-midi;\r\n\tname=Part .exe
        params = $2.to_s.split(/\s+/)
        params = params.map { |i| i.to_s.chomp.strip }
        params = params.map { |i| i.split(/\s*\=\s*/) }
        params = params.map { |i| "#{i[0]}=#{dquote(i[1].to_s)}" }.join('; ')
        "#{type}; #{params}"
      when val =~ /^\s*$/
        'text/plain'
      else
        ''
      end
    end
    
    def get_mime_type( val )
      case
      when val =~ /^([\w\d\-_]+)\/([\w\d\-_]+);.+$/i
        "#{$1}/#{$2}"
      else 
        'text/plain'
      end
    end
  end
end
