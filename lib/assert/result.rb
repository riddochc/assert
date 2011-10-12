module Assert; end
module Assert::Result

  class Base; end
  class Pass < Base; end
  class Ignore < Base; end
  class Fail < Base; end
  class Error < Base; end
  class Skip < Base; end

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
      line.rindex(ASSERT_DIR, 0)
    end

  end


  # Result classes...

  class Base

    attr_reader :test, :message, :backtrace

    def initialize(test, message, backtrace=nil)
      @test = test
      @backtrace = Backtrace.new(backtrace)
      @message = message && !message.empty? ? message : nil
    end

    Assert::Result.types.keys.each do |meth|
      define_method("#{meth}?") { false }
    end

    def test_name
      @test.name
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

  class Ignore < Base

    def ignore?; true; end
    def to_sym; :ignore; end

    def name
      "Ignore"
    end

  end

  # raised by the 'fail' context helper to break test execution
  # (if Test.halt_on_fail?)
  class TestFailure < RuntimeError; end

  class Fail < Base

    # fail results can be generated manually or by raising Assert::Result::TestFailure
    def initialize(test, message_or_exception, backtrace=nil)
      if message_or_exception.kind_of?(TestFailure)
        super(test, message_or_exception.message, message_or_exception.backtrace || [])
      elsif message_or_exception.kind_of?(Exception)
        raise ArgumentError, "generate fail results by raising Assert::Result::TestFailure"
      else
        super(test, message_or_exception, backtrace)
      end
    end

    def fail?; true; end
    def to_sym; :fail; end

    def name
      "Fail"
    end

    # override of the base, show the test's context info called_from
    def trace
      self.test.context_info.called_from || super
    end

  end

  # raised by the 'skip' context helper to break test execution
  class TestSkipped < RuntimeError; end

  class Skip < Base

    # skip results are generated by raising Assert::Result::TestSkipped
    def initialize(test, exception)
      if exception.kind_of?(TestSkipped)
        super(test, exception.message, exception.backtrace || [])
      else
        raise ArgumentError, "generate skip results by raising Assert::Result::TestSkipped"
      end
    end

    def skip?; true; end
    def to_sym; :skip; end

    def name
      "Skip"
    end

  end

  class Error < Base

    # error results are generated by raising exceptions in tests
    def initialize(test, exception)
      if exception.kind_of?(Exception)
        super(test, "#{exception.message} (#{exception.class.name})", exception.backtrace || [])
      else
        raise ArgumentError, "generate error results by raising an exception"
      end
    end

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
