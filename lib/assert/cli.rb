require 'set'
require 'assert/version'

module Assert

  class CLI

    def self.run(*args)
      self.new.run(*args)
    end

    def initialize
      @cli = CLIRB.new
    end

    def run(*args)
      begin
        @cli.parse!(*args)
        tests = @cli.args
        tests = ['test'] if tests.empty?
        Assert::CLIRunner.new(*tests).run
      rescue CLIRB::HelpExit
        puts help
      rescue CLIRB::VersionExit
        puts Assert::VERSION
      rescue CLIRB::Error => exception
        puts "#{exception.message}\n"
        puts help
        exit(1)
      rescue Exception => exception
        puts "#{exception.class}: #{exception.message}"
        puts exception.backtrace.join("\n") if ENV['DEBUG']
        exit(1)
      end

      # Don't call `exit(0)`.  The test suite runs as the by an `at_exit`
      # callback.  Calling `exit(0)` bypasses that callback.
    end

    def help
      "Usage: assert [TESTS] [options]\n\n"\
      "Options:"\
      "#{@cli}"
    end

  end

  class CLIRunner
    TEST_FILE_SUFFIXES = ['_tests.rb', '_test.rb']

    attr_reader :test_files

    def initialize(*args)
      options, test_paths = [
        args.last.kind_of?(::Hash) ? args.pop : {},
        args
      ]

      @test_files = file_paths(test_paths).select{ |f| test_file?(f) }
    end

    def run
      @test_files.each{ |file| require file }
      require 'assert' if @test_files.empty?  # show empty test output
    end

    private

    def file_paths(test_paths)
      test_paths.inject(Set.new) do |paths, path|
        paths += Dir.glob("#{path}*") + Dir.glob("#{path}*/**/*")
      end
    end

    def test_file?(path)
      TEST_FILE_SUFFIXES.inject(false) do |result, suffix|
        result || path =~ /#{suffix}$/
      end
    end
  end

  class CLIRB  # Version 1.0.0, https://github.com/redding/cli.rb
    Error    = Class.new(RuntimeError);
    HelpExit = Class.new(RuntimeError); VersionExit = Class.new(RuntimeError)
    attr_reader :argv, :args, :opts, :data

    def initialize(&block)
      @options = []; instance_eval(&block) if block
      require 'optparse'
      @data, @args, @opts = [], [], {}; @parser = OptionParser.new do |p|
        p.banner = ''; @options.each do |o|
          @opts[o.name] = o.value; p.on(*o.parser_args){ |v| @opts[o.name] = v }
        end
        p.on_tail('--version', ''){ |v| raise VersionExit, v.to_s }
        p.on_tail('--help',    ''){ |v| raise HelpExit,    v.to_s }
      end
    end

    def option(*args); @options << Option.new(*args); end
    def parse!(argv)
      @args = (argv || []).dup.tap do |args_list|
        begin; @parser.parse!(args_list)
        rescue OptionParser::ParseError => err; raise Error, err.message; end
      end; @data = @args + [@opts]
    end
    def to_s; @parser.to_s; end
    def inspect
      "#<#{self.class}:#{'0x0%x' % (object_id << 1)} @data=#{@data.inspect}>"
    end

    class Option
      attr_reader :name, :opt_name, :desc, :abbrev, :value, :klass, :parser_args

      def initialize(name, *args)
        settings, @desc = args.last.kind_of?(::Hash) ? args.pop : {}, args.pop || ''
        @name, @opt_name, @abbrev = parse_name_values(name, settings[:abbrev])
        @value, @klass = gvalinfo(settings[:value])
        @parser_args = if [TrueClass, FalseClass, NilClass].include?(@klass)
          ["-#{@abbrev}", "--[no-]#{@opt_name}", @desc]
        else
          ["-#{@abbrev}", "--#{@opt_name} #{@opt_name.upcase}", @klass, @desc]
        end
      end

      private

      def parse_name_values(name, custom_abbrev)
        [ (processed_name = name.to_s.strip.downcase), processed_name.gsub('_', '-'),
          custom_abbrev || processed_name.gsub(/[^a-z]/, '').chars.first || 'a'
        ]
      end
      def gvalinfo(v); v.kind_of?(Class) ? [nil,gklass(v)] : [v,gklass(v.class)]; end
      def gklass(k); k == Fixnum ? Integer : k; end
    end
  end

end