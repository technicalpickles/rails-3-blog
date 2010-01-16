require 'set'

module Rails
  class Application
    module PathParent
      def method_missing(id, *args)
        name = id.to_s

        if name =~ /^(.*)=$/ || args.any?
          @children[$1 || name] = Path.new(@root, *args)
        elsif path = @children[name]
          path
        else
          super
        end
      end
    end

    class Root
      include PathParent

      attr_accessor :path

      def initialize(path)
        raise if path.is_a?(Array)

        @children = {}

        @path = path
        @root = self
        @all_paths = []
      end

      def load_once
        all_paths.map { |path| path.paths if path.load_once? }.compact.flatten.uniq
      end

      def eager_load
        all_paths.map { |path| path.paths if path.eager_load? }.compact.flatten.uniq
      end

      def all_paths
        @all_paths.uniq!
        @all_paths
      end

      def load_paths
        all_paths.map { |path| path.paths if path.load_path? }.compact.flatten.uniq
      end

      def add_to_load_path
        load_paths.reverse_each do |path|
          $LOAD_PATH.unshift(path) if File.directory?(path)
        end
      end

      def push(*)
        raise "Application root can only have one physical path"
      end

      alias unshift push
      alias << push
      alias concat push
    end

    class Path
      include PathParent, Enumerable

      attr_reader :path
      attr_accessor :glob

      def initialize(root, *paths)
        @options  = paths.last.is_a?(::Hash) ? paths.pop : {}
        @children = {}
        @root     = root
        @paths    = paths.flatten
        @glob     = @options[:glob] || "**/*.rb"

        @load_once  = @options[:load_once]
        @eager_load = @options[:eager_load]
        @load_path  = @options[:load_path] || @eager_load

        @root.all_paths << self
      end

      def each
        to_a.each { |p| yield p }
      end

      def push(path)
        @paths.push path
      end

      alias << push

      def unshift(path)
        @paths.unshift path
      end

      def concat(paths)
        @paths.concat paths
      end

      def load_once!
        @load_once = true
      end

      def load_once?
        @load_once
      end

      def eager_load!
        @eager_load = true
        @load_path  = true
      end

      def eager_load?
        @eager_load
      end

      def load_path!
        @load_path = true
      end

      def load_path?
        @load_path
      end

      def paths
        raise "You need to set a path root" unless @root.path

        @paths.map do |path|
          path.index('/') == 0 ? path : File.expand_path(File.join(@root.path, path))
        end
      end

      alias to_a paths
    end
  end
end