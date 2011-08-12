require 'assert'

class Assert::Assertions::AssertNotInstanceOfTest < Assert::Context
  desc "the assert_not_instance_of helper run in a test"
  setup do
    fail_desc = @fail_desc = "assert not instance of fail desc"
    fail_args = @fail_args = [ String, "object", fail_desc ]
    @test = Factory.test do
      assert_not_instance_of(*fail_args)        # fail
      assert_not_instance_of(Array, "object")   # pass
    end
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
  
  class FailMessageTest < AssertNotInstanceOfTest
    desc "with a failed result"
    setup do
      @expected = [
        "#{@fail_args[1].inspect} was not expected to be an instance of #{@fail_args[0]}.",
        "\n#{@fail_args[2]}"
      ].join
      @fail_message = @test.fail_results.first.message
    end
    subject{ @fail_message }

    should "have a fail message with an explanation of what failed and my fail description" do
      assert_equal @expected, subject
    end

  end

end