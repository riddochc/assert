module Assert; end
module Assert::Result

  class Base; end
  class Pass < Base; end
  class Fail < Base; end
  class Ignore < Base; end
  class FromException < Base; end
  class Error < FromException; end
  class Skip < FromException; end

  class << self
    def types
      { :pass => Pass,
        :fail => Fail,
        :ignore => Ignore,
        :skip => Skip,
        :error => Error
      }
    end
  end

  class Backtrace < ::Array
    # ripped from minitest...

    file = File.expand_path __FILE__
           # if RUBY_VERSION =~ /^1\.9/ then  # bt's expanded, but __FILE__ isn't :(
           #    File.expand_path __FILE__
           # elsif  __FILE__ =~ /^[^\.]/ then # assume both relative
           #   require 'pathname'
           #   pwd = Pathname.new Dir.pwd
           #   pn = Pathname.new File.expand_path(__FILE__)
           #   relpath = pn.relative_path_from(pwd) rescue pn
           #   pn = File.join ".", relpath unless pn.relative?
           #   pn.to_s
           # else                             # assume both are expanded
           #   __FILE__
           # end

    # './lib' in project dir, or '/usr/local/blahblah' if installed
    ASSERT_DIR = File.dirname(File.dirname(file))
    MACROS_DIR = File.join(File.dirname(file), 'macros')

    def initialize(value=nil)
      super(value || ["No backtrace"])
    end

    def to_s
      self.join("\n")
    end

    def filtered
      new_bt = []

      self.each do |line|
        break if filter_out?(line)
        new_bt << line
      end

      new_bt = self.reject { |line| filter_out?(line) } if new_bt.empty?
      new_bt = self.dup if new_bt.empty?

      self.class.new(new_bt)
    end

    protected

    def filter_out?(line)
      line.rindex(ASSERT_DIR, 0) && !line.rindex(MACROS_DIR, 0)
    end

  end


  # Result classes...

  class Base

    attr_reader :test_name, :message, :backtrace

    def initialize(test_name, message, backtrace=nil)
      @backtrace = Backtrace.new(backtrace)
      @test_name = test_name
      @message = message && !message.empty? ? message : nil
    end

    Assert::Result.types.keys.each do |meth|
      define_method("#{meth}?") { false }
    end

    def to_sym; nil; end

    def to_s
      [ "#{self.name.upcase}: #{self.test_name}",
        self.message,
        self.trace
      ].compact.join("\n")
    end

    def name
      ""
    end

    def trace
      self.backtrace.filtered.first.to_s
    end

    def ==(other)
      self.class == other.class && self.message == other.message
    end

    def inspect
      "#<#{self.class} @message=#{self.message.inspect}>"
    end

  end

  class Pass < Base
    def pass?; true; end
    def to_sym; :pass; end

    def name
      "Pass"
    end
  end

  class Fail < Base
    def fail?; true; end
    def to_sym; :fail; end

    def name
      "Fail"
    end
  end

  class Ignore < Base
    def ignore?; true; end
    def to_sym; :ignore; end

    def name
      "Ignore"
    end
  end

  # Error and Skip results are built from exceptions being raised
  class FromException < Base

    def self.exception_result_msg(exception)
      if [ Assert::Result::TestSkipped ].include?(exception.class)
        exception.message
      else
        "#{exception.message} (#{exception.class.name})"
      end
    end

    def initialize(test_name, exception)
      super(test_name, self.class.exception_result_msg(exception), exception.backtrace || [])
    end
  end

  # raised by the 'skip' context helper to break test execution
  class TestSkipped < RuntimeError; end

  class Skip < FromException
    def skip?; true; end
    def to_sym; :skip; end

    def name
      "Skip"
    end
  end

  class Error < FromException

    def error?; true; end
    def to_sym; :error; end

    def name
      "Error"
    end

    # override of the base, always show the full unfiltered backtrace for errors
    def trace
      self.backtrace.to_s
    end
  end

end
