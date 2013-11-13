require 'assert/utils'

module Assert

  module Assertions

    def assert_block(desc = nil)
      assert(yield, desc){ "Expected block to return a true value." }
    end

    def assert_not_block(desc = nil)
      assert(!yield, desc){ "Expected block to return a false value." }
    end
    alias_method :refute_block, :assert_not_block

    def assert_empty(collection, desc = nil)
      assert(collection.empty?, desc) do
        "Expected #{Assert::U.pp(collection)} to be empty."
      end
    end

    def assert_not_empty(collection, desc = nil)
      assert(!collection.empty?, desc) do
        "Expected #{Assert::U.pp(collection)} to not be empty."
      end
    end
    alias_method :refute_empty, :assert_not_empty

    def assert_equal(expected, actual, desc = nil)
      assert(actual == expected, desc) do
        "Expected #{Assert::U.pp(expected)}, not #{Assert::U.pp(actual)}."
      end
    end

    def assert_not_equal(expected, actual, desc = nil)
      assert(actual != expected, desc) do
        "#{Assert::U.pp(actual)} not expected to equal #{Assert::U.pp(expected)}."
      end
    end
    alias_method :refute_equal, :assert_not_equal

    def assert_file_exists(file_path, desc = nil)
      assert(File.exists?(File.expand_path(file_path)), desc) do
        "Expected #{Assert::U.pp(file_path)} to exist."
      end
    end

    def assert_not_file_exists(file_path, desc = nil)
      assert(!File.exists?(File.expand_path(file_path)), desc) do
        "Expected #{Assert::U.pp(file_path)} to not exist."
      end
    end
    alias_method :refute_file_exists, :assert_not_file_exists

    def assert_includes(object, collection, desc = nil)
      assert(collection.include?(object), desc) do
        "Expected #{Assert::U.pp(collection)} to include #{Assert::U.pp(object)}."
      end
    end
    alias_method :assert_included, :assert_includes

    def assert_not_includes(object, collection, desc = nil)
      assert(!collection.include?(object), desc) do
        "Expected #{Assert::U.pp(collection)} to not include #{Assert::U.pp(object)}."
      end
    end
    alias_method :assert_not_included, :assert_not_includes
    alias_method :refute_includes, :assert_not_includes
    alias_method :refute_included, :assert_not_includes

    def assert_instance_of(klass, instance, desc = nil)
      assert(instance.instance_of?(klass), desc) do
        "Expected #{Assert::U.pp(instance)} (#{instance.class}) to be an instance of #{klass}."
      end
    end

    def assert_not_instance_of(klass, instance, desc = nil)
      assert(!instance.instance_of?(klass), desc) do
        "#{Assert::U.pp(instance)} (#{instance.class}) not expected to be an instance of #{klass}."
      end
    end
    alias_method :refute_instance_of, :assert_not_instance_of

    def assert_kind_of(klass, instance, desc=nil)
      assert(instance.kind_of?(klass), desc) do
        "Expected #{Assert::U.pp(instance)} (#{instance.class}) to be a kind of #{klass}."
      end
    end

    def assert_not_kind_of(klass, instance, desc=nil)
      assert(!instance.kind_of?(klass), desc) do
        "#{Assert::U.pp(instance)} not expected to be a kind of #{klass}."
      end
    end
    alias_method :refute_kind_of, :assert_not_kind_of

    def assert_match(expected, actual, desc=nil)
      exp = String === expected && String === actual ? /#{Regexp.escape(expected)}/ : expected
      assert(actual =~ exp, desc) do
        "Expected #{Assert::U.pp(actual)} to match #{Assert::U.pp(expected)}."
      end
    end

    def assert_not_match(expected, actual, desc=nil)
      exp = String === expected && String === actual ? /#{Regexp.escape(expected)}/ : expected
      assert(actual !~ exp, desc) do
        "#{Assert::U.pp(actual)} not expected to match #{Assert::U.pp(expected)}."
      end
    end
    alias_method :refute_match, :assert_not_match
    alias_method :assert_no_match, :assert_not_match

    def assert_nil(object, desc=nil)
      assert(object.nil?, desc){ "Expected nil, not #{Assert::U.pp(object)}." }
    end

    def assert_not_nil(object, desc=nil)
      assert(!object.nil?, desc){ "Expected #{Assert::U.pp(object)} to not be nil." }
    end
    alias_method :refute_nil, :assert_not_nil

    def assert_raises(*exceptions, &block)
      desc = exceptions.last.kind_of?(String) ? exceptions.pop : nil
      err = RaisedException.new(exceptions, &block)
      assert(err.raised?, desc){ err.msg }
    end
    alias_method :assert_raise, :assert_raises

    def assert_nothing_raised(*exceptions, &block)
      desc = exceptions.last.kind_of?(String) ? exceptions.pop : nil
      err = NoRaisedException.new(exceptions, &block)
      assert(!err.raised?, desc){ err.msg }
    end
    alias_method :assert_not_raises, :assert_nothing_raised
    alias_method :assert_not_raise, :assert_nothing_raised

    def assert_respond_to(method, object, desc=nil)
      assert(object.respond_to?(method), desc) do
        "Expected #{Assert::U.pp(object)} (#{object.class}) to respond to `#{method}`."
      end
    end
    alias_method :assert_responds_to, :assert_respond_to

    def assert_not_respond_to(method, object, desc=nil)
      assert(!object.respond_to?(method), desc) do
        "#{Assert::U.pp(object)} (#{object.class}) not expected to respond to `#{method}`."
      end
    end
    alias_method :assert_not_responds_to, :assert_not_respond_to
    alias_method :refute_respond_to, :assert_not_respond_to
    alias_method :refute_responds_to, :assert_not_respond_to

    def assert_same(expected, actual, desc=nil)
      assert(actual.equal?(expected), desc) do
        "Expected #{Assert::U.pp(actual)} (#{actual.object_id})"\
        " to be the same as #{Assert::U.pp(expected)} (#{expected.object_id})."
      end
    end

    def assert_not_same(expected, actual, desc=nil)
      assert(!actual.equal?(expected), desc) do
        "#{Assert::U.pp(actual)} (#{actual.object_id})"\
        " not expected to be the same as #{Assert::U.pp(expected)} (#{expected.object_id})."
      end
    end
    alias_method :refute_same, :assert_not_same

    # ignored assertion helpers

    IGNORED_ASSERTION_HELPERS = [
      :assert_throws,     :assert_nothing_thrown,
      :assert_operator,   :refute_operator,
      :assert_in_epsilon, :refute_in_epsilon,
      :assert_in_delta,   :refute_in_delta,
      :assert_send
    ]
    def method_missing(method, *args, &block)
      if IGNORED_ASSERTION_HELPERS.include?(method.to_sym)
        ignore "The assertion `#{method}` is not supported."\
               " Please use another assertion or the basic `assert`."
      else
        super
      end
    end

    # exception raised utility classes

    class CheckException
      attr_reader :msg, :exception

      def initialize(exceptions, &block)
        @exceptions = exceptions
        begin; block.call; rescue Exception => @exception; end
        @msg = "#{exceptions_sentence(@exceptions)} #{exception_details}"
      end

      def raised?
        !@exception.nil? && is_one_of?(@exception, @exceptions)
      end

      private

      def is_one_of?(exception, exceptions)
        exceptions.empty? || exceptions.any? do |exp|
          exp.instance_of?(Module) ? exception.kind_of?(exp) : exception.class == exp
        end
      end

      def exceptions_sentence(exceptions)
        if exceptions.size <= 1
          (exceptions.first || "An").to_s
        else
          "#{exceptions[0..-2].join(", ")} or #{exceptions[-1]}"
        end
      end

      def exception_details(raised_msg=nil, no_raised_msg=nil)
        if @exception
          backtrace = Assert::Result::Backtrace.new(@exception.backtrace)
          [ raised_msg,
            "Class: `#{@exception.class}`",
            "Message: `#{@exception.message.inspect}`",
            "---Backtrace---",
            backtrace.filtered.to_s,
            "---------------"
          ].compact.join("\n")
        else
          no_raised_msg
        end
      end
    end

    class RaisedException < CheckException
      def exception_details
        super("exception expected, not:", "exception expected but nothing raised.")
      end
    end

    class NoRaisedException < CheckException
      def exception_details
        super("exception not expected, but raised:")
      end
    end

  end

end
