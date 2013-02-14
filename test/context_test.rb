require 'assert'

class Assert::Context

  class BasicTest < Assert::Context
    desc "Assert context"
    setup do
      @test = Factory.test
      @context_class = @test.context_class
      @context = @context_class.new(@test)
    end
    teardown do
      TEST_ASSERT_SUITE.tests.clear
    end
    subject{ @context }

    should have_instance_methods :assert, :assert_not, :refute
    should have_instance_methods :skip, :pass, :fail, :flunk, :ignore
    should have_instance_methods :subject

    def test_should_collect_context_info
      assert_match /test\/context_test.rb$/, @__running_test__.context_info.file
      assert_equal self.class, @__running_test__.context_info.klass
    end

  end



  class SkipTest < BasicTest
    desc "skip method"
    setup do
      @skip_msg = "I need to implement this in the future."
      begin
        @context.skip(@skip_msg)
      rescue Exception => @exception
      end
      @result = Factory.skip_result("something", @exception)
    end
    subject{ @result }

    should "raise a test skipped exception when called" do
      assert_kind_of Assert::Result::TestSkipped, @exception
    end
    should "raise the exception with the message passed to it" do
      assert_equal @skip_msg, @exception.message
    end
    should "set the message passed to it on the result" do
      assert_equal @skip_msg, subject.message
    end

  end



  class IgnoreTest < BasicTest
    desc "ignore method"
    setup do
      @ignore_msg = "Ignore this for now, will do later."
      @result = @context.ignore(@ignore_msg)
    end
    subject{ @result }

    should "create an ignore result" do
      assert_kind_of Assert::Result::Ignore, subject
    end
    should "set the messaged passed to it on the result" do
      assert_equal @ignore_msg, subject.message
    end

  end



  class PassTest < BasicTest
    desc "pass method"
    setup do
      @pass_msg = "That's right, it works."
      @result = @context.pass(@pass_msg)
    end
    subject{ @result }

    should "create a pass result" do
      assert_kind_of Assert::Result::Pass, subject
    end
    should "set the messaged passed to it on the result" do
      assert_equal @pass_msg, subject.message
    end

  end



  class FlunkTests < BasicTest
    desc "flunk method"
    setup do
      @flunk_msg = "It flunked."
      @result = @context.flunk(@flunk_msg)
    end
    subject{ @result }

    should "create a fail result" do
      assert_kind_of Assert::Result::Fail, subject
    end
    should "set the message passed to it on the result" do
      assert_equal @flunk_msg, subject.message
    end

  end

  class FailTests < BasicTest
    desc "fail method"
    setup do
      @result = @context.fail
    end
    subject{ @result }

    should "create a fail result" do
      assert_kind_of Assert::Result::Fail, subject
    end
    should "set the calling backtrace on the result" do
      assert_kind_of Array, subject.backtrace
      assert_equal Factory.context_info_called_from, subject.trace
    end
  end

  class StringMessageTests < FailTests
    desc "with a string message"
    setup do
      @fail_msg = "Didn't work"
      @result = @context.fail(@fail_msg)
    end

    should "set the message passed to it on the result" do
      assert_equal @fail_msg, subject.message
    end

  end

  class ProcMessageTests < FailTests
    desc "with a proc message"
    setup do
      @fail_msg = ::Proc.new{ "Still didn't work" }
      @result = @context.fail(@fail_msg)
    end

    should "set the message passed to it on the result" do
      assert_equal @fail_msg.call, subject.message
    end

  end

  class HaltOnFailTests < FailTests
    desc "when halting on fails"
    setup do
      @orig_halt_fail = Assert.config.halt_on_fail
      @fail_msg = "something failed"
    end
    teardown do
      Assert.config.halt_on_fail @orig_halt_fail
    end
    subject{ @result }

    should "raise an exception with the failure's message" do
      Assert.config.halt_on_fail true
      err = begin
        @context.fail @fail_msg
      rescue Exception => exception
        exception
      end
      assert_kind_of Assert::Result::TestFailure, err
      assert_equal @fail_msg, err.message

      result = Assert::Result::Fail.new(Factory.test("something"), err)
      assert_equal @fail_msg, result.message
    end

  end



  class AssertTest < BasicTest
    desc "assert method"
    setup do
      @fail_desc = "my fail desc"
      @what_failed = "what failed"
    end

    class WithTruthyAssertionTest < AssertTest
      desc "with a truthy assertion"
      setup do
        @result = @context.assert(true, @fail_desc, @what_failed)
      end
      subject{ @result }

      should "return a pass result" do
        assert_kind_of Assert::Result::Pass, subject
        assert_nil subject.message
      end

    end

    class WithFalseAssertionTest < AssertTest
      desc "with a false assertion"
      setup do
        @result = @context.assert(false, @fail_desc, @what_failed)
      end
      subject{ @result }

      should "return a fail result" do
        assert_kind_of Assert::Result::Fail, subject
        assert_equal [@fail_desc, @what_failed].join("\n"), subject.message
      end

    end

    # extras

    should "return a pass result with a truthy (34) assertion" do
      assert_kind_of Assert::Result::Pass, subject.assert(34)
    end

    should "return a fail result with a nil assertion" do
      assert_kind_of Assert::Result::Fail, subject.assert(nil)
    end

  end



  class AssertNotTest < BasicTest
    desc "assert_not method"
    setup do
      @fail_desc = "my fail desc"
    end

    class WithTruthyAssertionTest < AssertNotTest
      desc "with a truthy assertion"
      setup do
        @what_failed = "Failed assert_not: assertion was <true>."
        @result = @context.assert_not(true, @fail_desc)
      end
      subject{ @result }

      should "return a fail result" do
        assert_kind_of Assert::Result::Fail, subject
        assert_equal [@fail_desc, @what_failed].join("\n"), subject.message
      end

    end

    class WithFalseAssertionTest < AssertNotTest
      desc "with a false assertion"
      setup do
        @result = @context.assert_not(false, @fail_desc)
      end
      subject{ @result }

      should "return a pass result" do
        assert_kind_of Assert::Result::Pass, subject
        assert_nil subject.message
      end

    end

    # extras

    should "return a fail result with a truthy (34) assertion" do
      assert_kind_of Assert::Result::Fail, subject.assert_not(34)
    end

    should "return a pass result with a nil assertion" do
      assert_kind_of Assert::Result::Pass, subject.assert_not(nil)
    end

  end



  class SubjectTest < BasicTest
    desc "subject method"
    setup do
      expected = @expected = "amazing"
      @context_class = Factory.context_class do
        subject{ @something = expected }
      end
      @context = @context_class.new
      @subject = @context.subject
    end
    subject{ @subject }

    should "instance evaluate the block set with the class setup method" do
      assert_equal @expected, subject
    end

  end



  class InspectTest < BasicTest
    desc "inspect method"
    setup do
      @expected = "#<#{@context.class}>"
      @inspect = @context.inspect
    end
    subject{ @inspect }

    should "just show the name of the class" do
      assert_equal @expected, subject
    end
  end

end
