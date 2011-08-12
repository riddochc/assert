root_path = File.expand_path("../..", __FILE__)
if !$LOAD_PATH.include?(root_path)
  $LOAD_PATH.unshift(root_path)
end
require 'test/helper'

class Assert::Assertions::BasicTest < Assert::Context

  desc "An assert context"
  setup do
    @context_class = Factory.context_class
    @context = @context_class.new
  end
  subject{ @context }

  INSTANCE_METHODS = [
    :assert_block, :assert_not_block, :refute_block,
    :assert_raises, :assert_raise, :assert_nothing_raised, :assert_not_raises, :assert_not_raise,
    :assert_kind_of, :assert_not_kind_of, :refute_kind_of,
    :assert_instance_of, :assert_not_instance_of, :refute_instance_of,
    :assert_respond_to, :assert_not_respond_to, :refute_respond_to,
    :assert_same, :assert_not_same, :refute_same,
    :assert_equal, :assert_not_equal, :refute_equal,
    :assert_match, :assert_not_match, :assert_no_match, :refute_match
  ]
  INSTANCE_METHODS.each do |method|
    should "respond to the instance method ##{method}" do
      assert_respond_to subject, method
    end
  end

end

=begin
module Assert::Assertions

  class AssertKindOfTest < BasicTest

    setup do
      @test = Assert::Test.new("assert kind of test", lambda do
        assert_kind_of(String, "object")  # pass
        assert_kind_of(Array, "object")   # fail
      end, @context_klass)
      @test.run
    end
    subject{ @test }

    should "have 2 total results" do
      assert_equal 2, subject.result_count
    end

    should "have 1 pass result" do
      assert_equal 1, subject.result_count(:pass)
    end

    should "have 1 fail result" do
      assert_equal 1, subject.result_count(:fail)
    end

    class MessagesTest < AssertKindOfTest

      setup do
        args = [ Array, "object", "assert kind of shouldn't fail!" ]
        @test = Assert::Test.new("assert kind of message test", lambda do
          assert_kind_of(*args)
        end, @context_klass)
        @expected_message = "Expected #{args[1].inspect} to be a kind of #{args[0]}, not #{args[1].class}.\n#{args[2]}"
        @test.run
        @message = @test.fail_results.first.message
      end
      subject{ @message }

      should "have the correct failure message" do
        assert_equal @expected_message, subject
      end

    end

  end

  class AssertNotKindOfTest < BasicTest

    setup do
      @test = Assert::Test.new("assert not kind of test", lambda do
        assert_not_kind_of(String, "object")  # fail
        assert_not_kind_of(Array, "object")   # pass
      end, @context_klass)
      @test.run
    end
    subject{ @test }

    should "have 2 total results" do
      assert_equal 2, subject.result_count
    end

    should "have 1 pass result" do
      assert_equal 1, subject.result_count(:pass)
    end

    should "have 1 fail result" do
      assert_equal 1, subject.result_count(:fail)
    end

    class MessagesTest < AssertNotKindOfTest

      setup do
        args = [ String, "object", "assert not kind of shouldn't fail!" ]
        @test = Assert::Test.new("assert not kind of message test", lambda do
          assert_not_kind_of(*args)
        end, @context_klass)
        @expected_message = "#{args[1].inspect} was not expected to be a kind of #{args[0]}.\n#{args[2]}"
        @test.run
        @message = @test.fail_results.first.message
      end
      subject{ @message }

      should "have the correct failure message" do
        assert_equal @expected_message, subject
      end

    end

  end



  class AssertInstanceOfTest < BasicTest

    setup do
      @test = Assert::Test.new("assert instance of test", lambda do
        assert_instance_of(String, "object")  # pass
        assert_instance_of(Array, "object")   # fail
      end, @context_klass)
      @test.run
    end
    subject{ @test }

    should "have 2 total results" do
      assert_equal 2, subject.result_count
    end

    should "have 1 pass result" do
      assert_equal 1, subject.result_count(:pass)
    end

    should "have 1 fail result" do
      assert_equal 1, subject.result_count(:fail)
    end

    class MessagesTest < AssertInstanceOfTest

      setup do
        args = [ Array, "object", "assert instance of shouldn't fail!" ]
        @test = Assert::Test.new("assert instance of message test", lambda do
          assert_instance_of(*args)
        end, @context_klass)
        @expected_message = "Expected #{args[1].inspect} to be an instance of #{args[0]}, not #{args[1].class}.\n#{args[2]}"
        @test.run
        @message = @test.fail_results.first.message
      end
      subject{ @message }

      should "have the correct failure message" do
        assert_equal @expected_message, subject
      end

    end

  end

  class AssertNotInstanceOfTest < BasicTest

    setup do
      @test = Assert::Test.new("assert not instance of test", lambda do
        assert_not_instance_of(String, "object")  # fail
        assert_not_instance_of(Array, "object")   # pass
      end, @context_klass)
      @test.run
    end
    subject{ @test }

    should "have 2 total results" do
      assert_equal 2, subject.result_count
    end

    should "have 1 pass result" do
      assert_equal 1, subject.result_count(:pass)
    end

    should "have 1 fail result" do
      assert_equal 1, subject.result_count(:fail)
    end

    class MessagesTest < AssertNotInstanceOfTest

      setup do
        args = [ String, "object", "assert not instance of shouldn't fail!" ]
        @test = Assert::Test.new("assert not instance of message test", lambda do
          assert_not_instance_of(*args)
        end, @context_klass)
        @expected_message = "#{args[1].inspect} was not expected to be an instance of #{args[0]}.\n#{args[2]}"
        @test.run
        @message = @test.fail_results.first.message
      end
      subject{ @message }

      should "have the correct failure message" do
        assert_equal @expected_message, subject
      end

    end

  end



  class AssertRespondToTest < BasicTest

    setup do
      @test = Assert::Test.new("assert respond to test", lambda do
        assert_respond_to(1, :abs)      # pass
        assert_respond_to("1", :abs)    # fail
      end, @context_klass)
      @test.run
    end
    subject{ @test }

    should "have 2 total results" do
      assert_equal 2, subject.result_count
    end

    should "have 1 pass result" do
      assert_equal 1, subject.result_count(:pass)
    end

    should "have 1 fail result" do
      assert_equal 1, subject.result_count(:fail)
    end

    class MessagesTest < AssertRespondToTest

      setup do
        args = [ "1", :abs, "assert respond to shouldn't fail!" ]
        @test = Assert::Test.new("assert respond to message test", lambda do
          assert_respond_to(*args)
        end, @context_klass)
        @expected_message = "Expected #{args[0].inspect} (#{args[0].class}) to respond to ##{args[1]}.\n#{args[2]}"
        @test.run
        @message = @test.fail_results.first.message
      end
      subject{ @message }

      should "have the correct failure message" do
        assert_equal @expected_message, subject
      end

    end

  end

  class AssertNotRespondToTest < BasicTest

    setup do
      @test = Assert::Test.new("assert not respond to test", lambda do
        assert_not_respond_to(1, :abs)     # fail
        assert_not_respond_to("1", :abs)   # pass
      end, @context_klass)
      @test.run
    end
    subject{ @test }

    should "have 2 total results" do
      assert_equal 2, subject.result_count
    end

    should "have 1 pass result" do
      assert_equal 1, subject.result_count(:pass)
    end

    should "have 1 fail result" do
      assert_equal 1, subject.result_count(:fail)
    end

    class MessagesTest < AssertNotRespondToTest

      setup do
        args = [ 1, :abs, "assert not respond to shouldn't fail!" ]
        @test = Assert::Test.new("assert not respond to message test", lambda do
          assert_not_respond_to(*args)
        end, @context_klass)
        @expected_message = "#{args[0].inspect} (#{args[0].class}) not expected to respond to ##{args[1]}.\n#{args[2]}"
        @test.run
        @message = @test.fail_results.first.message
      end
      subject{ @message }

      should "have the correct failure message" do
        assert_equal @expected_message, subject
      end

    end

  end

  class AssertSameTest < BasicTest

    setup do
      klass = Class.new
      object = klass.new
      @test = Assert::Test.new("assert same test", lambda do
        assert_same(object, object)     # pass
        assert_same(object, klass.new)  # fail
      end, @context_klass)
      @test.run
    end
    subject{ @test }

    should "have 2 total results" do
      assert_equal 2, subject.result_count
    end

    should "have 1 pass result" do
      assert_equal 1, subject.result_count(:pass)
    end

    should "have 1 fail result" do
      assert_equal 1, subject.result_count(:fail)
    end

    class MessagesTest < AssertSameTest

      setup do
        klass = Class.new
        args = [ klass.new, klass.new, "assert same shoudn't fail!" ]
        @test = Assert::Test.new("assert same message test", lambda do
          assert_same(*args)
        end, @context_klass)
        @expected_message = "Expected #{args[0].inspect} (#{args[0].object_id}) to be the same as #{args[1]} (#{args[1].object_id}).\n#{args[2]}"
        @test.run
        @message = @test.fail_results.first.message
      end
      subject{ @message }

      should "have the correct failure message" do
        assert_equal @expected_message, subject
      end

    end

  end

  class AssertNotSameTest < BasicTest

    setup do
      klass = Class.new
      object = klass.new
      @test = Assert::Test.new("assert not same test", lambda do
        assert_not_same(object, object)     # fail
        assert_not_same(object, klass.new)  # pass
      end, @context_klass)
      @test.run
    end
    subject{ @test }

    should "have 2 total results" do
      assert_equal 2, subject.result_count
    end

    should "have 1 pass result" do
      assert_equal 1, subject.result_count(:pass)
    end

    should "have 1 fail result" do
      assert_equal 1, subject.result_count(:fail)
    end

    class MessagesTest < AssertNotSameTest

      setup do
        klass = Class.new
        object = klass.new
        args = [ object, object, "assert not same shoudn't fail!" ]
        @test = Assert::Test.new("assert not same message test", lambda do
          assert_not_same(*args)
        end, @context_klass)
        @expected_message = "#{args[0].inspect} (#{args[0].object_id}) not expected to be the same as #{args[1]} (#{args[1].object_id}).\n#{args[2]}"
        @test.run
        @message = @test.fail_results.first.message
      end
      subject{ @message }

      should "have the correct failure message" do
        assert_equal @expected_message, subject
      end

    end

  end



  class AssertEqualTest < BasicTest

    setup do
      @test = Assert::Test.new("assert equal test", lambda do
        assert_equal(1, 1)  # pass
        assert_equal(1, 2)  # fail
      end, @context_klass)
      @test.run
    end
    subject{ @test }

    should "have 2 total results" do
      assert_equal 2, subject.result_count
    end

    should "have 1 pass result" do
      assert_equal 1, subject.result_count(:pass)
    end

    should "have 1 fail result" do
      assert_equal 1, subject.result_count(:fail)
    end

    class MessagesTest < AssertEqualTest

      setup do
        args = [ 1, 2, "assert equal shoudn't fail!" ]
        @test = Assert::Test.new("assert equal message test", lambda do
          assert_equal(*args)
        end, @context_klass)
        @expected_message = "Expected #{args[0].inspect}, not #{args[1].inspect}.\n#{args[2]}"
        @test.run
        @message = @test.fail_results.first.message
      end
      subject{ @message }

      should "have the correct failure message" do
        assert_equal @expected_message, subject
      end

    end

  end

  class AssertNotEqualTest < BasicTest

    setup do
      @test = Assert::Test.new("assert not equal test", lambda do
        assert_not_equal(1, 1)  # fail
        assert_not_equal(1, 2)  # pass
      end, @context_klass)
      @test.run
    end
    subject{ @test }

    should "have 2 total results" do
      assert_equal 2, subject.result_count
    end

    should "have 1 pass result" do
      assert_equal 1, subject.result_count(:pass)
    end

    should "have 1 fail result" do
      assert_equal 1, subject.result_count(:fail)
    end

    class MessagesTest < AssertNotEqualTest

      setup do
        args = [ 1, 1, "assert not equal shoudn't fail!" ]
        @test = Assert::Test.new("assert not equal message test", lambda do
          assert_not_equal(*args)
        end, @context_klass)
        @expected_message = "#{args[0].inspect} not expected to be equal to #{args[1].inspect}.\n#{args[2]}"
        @test.run
        @message = @test.fail_results.first.message
      end
      subject{ @message }

      should "have the correct failure message" do
        assert_equal @expected_message, subject
      end

    end

  end



  class AssertMatchTest < BasicTest

    setup do
      @test = Assert::Test.new("assert match test", lambda do
        assert_match("a string", /a/)     # pass
        assert_match("a string", "not")   # fail
      end, @context_klass)
      @test.run
    end
    subject{ @test }

    should "have 2 total results" do
      assert_equal 2, subject.result_count
    end

    should "have 1 pass result" do
      assert_equal 1, subject.result_count(:pass)
    end

    should "have 1 fail result" do
      assert_equal 1, subject.result_count(:fail)
    end

    class MessagesTest < AssertMatchTest

      setup do
        args = [ "a string", "not", "assert match shoudn't fail!" ]
        @test = Assert::Test.new("assert match message test", lambda do
          assert_match(*args)
        end, @context_klass)
        @expected_message = "Expected #{args[0].inspect} to match #{args[1].inspect}.\n#{args[2]}"
        @test.run
        @message = @test.fail_results.first.message
      end
      subject{ @message }

      should "have the correct failure message" do
        assert_equal @expected_message, subject
      end

    end

  end

  class AssertNotMatchTest < BasicTest

    setup do
      @test = Assert::Test.new("assert not match test", lambda do
        assert_not_match("a string", /a/)     # fail
        assert_not_match("a string", "not")   # pass
      end, @context_klass)
      @test.run
    end
    subject{ @test }

    should "have 2 total results" do
      assert_equal 2, subject.result_count
    end

    should "have 1 pass result" do
      assert_equal 1, subject.result_count(:pass)
    end

    should "have 1 fail result" do
      assert_equal 1, subject.result_count(:fail)
    end

    class MessagesTest < AssertNotMatchTest

      setup do
        args = [ "a string", /a/, "assert not match shoudn't fail!" ]
        @test = Assert::Test.new("assert not match message test", lambda do
          assert_not_match(*args)
        end, @context_klass)
        @expected_message = "#{args[0].inspect} not expected to match #{args[1].inspect}.\n#{args[2]}"
        @test.run
        @message = @test.fail_results.first.message
      end
      subject{ @message }

      should "have the correct failure message" do
        assert_equal @expected_message, subject
      end

    end

  end

  class IgnoredTest < BasicTest

    setup do
      @tests = Assert::Assertions::IGNORED_ASSERTION_HELPERS.collect do |helper|
        Assert::Test.new("ignored #{helper} test", lambda do
          self.send(helper, "doesn't matter")
        end, @context_klass)
      end
      @expected_messages = Assert::Assertions::IGNORED_ASSERTION_HELPERS.collect do |helper|
        [ "The assertion helper '#{helper}' is not supported. Please use ",
          "another helper or the basic assert."
        ].join
      end
      @results = @tests.collect(&:run).flatten
    end
    subject{ @results }

    should "have an ignored result for each helper in the constant" do
      subject.each do |result|
        assert_kind_of Assert::Result::Ignore, result
      end
      assert_equal(Assert::Assertions::IGNORED_ASSERTION_HELPERS.size, subject.size)
    end
    should "have a custom ignore message for each helper in the constant" do
      assert_equal(@expected_messages, subject.collect(&:message))
    end

  end

end
=end