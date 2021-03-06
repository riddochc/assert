module Assert; end
module Assert::Result

  class Base; end
  class Pass < Base; end
  class Ignore < Base; end
  class Fail < Base; end
  class Error < Base; end
  class Skip < Base; end

  def self.types
    @types ||= Hash.new{ |h, k| Base }.tap do |hash|
      hash[:pass]   = Pass
      hash[:fail]   = Fail
      hash[:ignore] = Ignore
      hash[:skip]   = Skip
      hash[:error]  = Error
    end.freeze
  end

  def self.new(data = nil)
    data ||= {}
    self.types[data[:type]].new(data)
  end

  class Base

    def self.type; :unknown; end
    def self.name; '';       end

    def self.for_test(test, message, bt)
      self.new({
        :test_name => test.name,
        :message   => message,
        :output    => test.output,
        :backtrace => Backtrace.new(bt)
      })
    end

    def initialize(build_data)
      @build_data = build_data
    end

    def type;      @type      ||= (@build_data[:type]      || self.class.type).to_sym;      end
    def name;      @name      ||= (@build_data[:name]      || self.class.name.to_s);        end
    def test_name; @test_name ||= (@build_data[:test_name] || '');                          end
    def message;   @message   ||= (@build_data[:message]   || '');                          end
    def output;    @output    ||= (@build_data[:output]    || '');                          end
    def backtrace; @backtrace ||= (@build_data[:backtrace] || Backtrace.new([]));           end
    def trace;     @trace     ||= (@build_data[:trace]     || build_trace(self.backtrace)); end

    Assert::Result.types.keys.each do |type|
      define_method("#{type}?"){ self.type == type }
    end

    # we choose to implement this way instead of using an `attr_writer` to be
    # consistant with how you override exception backtraces.
    def set_backtrace(bt)
      @backtrace = Backtrace.new(bt)
      @trace     = build_trace(@backtrace)
    end

    def data
      { :type      => self.type,
        :name      => self.name,
        :test_name => self.test_name,
        :message   => self.message,
        :output    => self.output,
        :backtrace => self.backtrace,
        :trace     => self.trace,
      }
    end

    def to_sym; self.type; end

    def to_s
      [ "#{self.name.upcase}: #{self.test_name}",
        self.message,
        self.trace
      ].reject(&:empty?).join("\n")
    end

    def ==(other_result)
      self.type == other_result.type && self.message == other_result.message
    end

    def inspect
      "#<#{self.class}:#{'0x0%x' % (object_id << 1)} @message=#{self.message.inspect}>"
    end

    private

    # by default, a result's trace is the first line of its filtered backtrace
    def build_trace(backtrace); backtrace.filtered.first.to_s; end

  end

  class Pass < Base

    def self.type; :pass;  end
    def self.name; 'Pass'; end

  end

  class Ignore < Base

    def self.type; :ignore;  end
    def self.name; 'Ignore'; end

  end

  # raised by the 'fail' context helper to break test execution
  TestFailure = Class.new(RuntimeError)

  class Fail < Base

    def self.type; :fail;  end
    def self.name; 'Fail'; end

    # fail results can be generated manually or by raising Assert::Result::TestFailure
    def self.for_test(test, message_or_exception, bt = nil)
      if message_or_exception.kind_of?(TestFailure)
        super(test, message_or_exception.message, message_or_exception.backtrace)
      elsif message_or_exception.kind_of?(Exception)
        raise ArgumentError, "generate fail results by raising Assert::Result::TestFailure"
      else
        super(test, message_or_exception, bt)
      end
    end

  end

  # raised by the 'skip' context helper to break test execution
  TestSkipped = Class.new(RuntimeError)

  class Skip < Base

    def self.type; :skip;  end
    def self.name; 'Skip'; end

    # skip results are generated by raising Assert::Result::TestSkipped
    def self.for_test(test, exception)
      if exception.kind_of?(TestSkipped)
        super(test, exception.message, exception.backtrace)
      else
        raise ArgumentError, "generate skip results by raising Assert::Result::TestSkipped"
      end
    end

  end

  class Error < Base

    def self.type; :error;  end
    def self.name; 'Error'; end

    # error results are generated by raising exceptions in tests
    def self.for_test(test, exception)
      if exception.kind_of?(Exception)
        super(test, "#{exception.message} (#{exception.class.name})", exception.backtrace)
      else
        raise ArgumentError, "generate error results by raising an exception"
      end
    end

    private

    # override of the base, always show the full unfiltered backtrace for errors
    def build_trace(backtrace); backtrace.to_s; end

  end

  class Backtrace < ::Array

    DELIM = "\n".freeze

    def self.parse(bt); self.new(bt.to_s.split(DELIM)); end

    def initialize(value = nil)
      super([*(value || "No backtrace")])
    end

    def to_s; self.join(DELIM); end

    def filtered
      self.class.new(self.reject { |line| filter_out?(line) })
    end

    protected

    # filter a line out if it's an assert lib/bin line
    def filter_out?(line)
      # './lib' in project dir, or '/usr/local/blahblah' if installed
      assert_lib_path = File.expand_path('../..', __FILE__)
      assert_bin_regex = /bin\/assert\:/
      line.rindex(assert_lib_path, 0) || line =~ assert_bin_regex
    end

  end

end
