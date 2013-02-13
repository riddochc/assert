require 'assert'

class Assert::Assertions::AssertNotFileExistsTests < Assert::Context
  desc "the assert_not_file_exists helper run in a test"
  setup do
    fail_desc = @fail_desc = "assert not file exists empty fail desc"
    fail_args = @fail_args = [ __FILE__, fail_desc ]
    @test = Factory.test do
      assert_not_file_exists('/a/path/to/some/file/that/no/exists') # pass
      assert_not_file_exists(*fail_args) # fail
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

  class FailMessageTest < AssertNotFileExistsTests
    desc "with a failed result"
    setup do
      @expected = [
        @fail_args[1],
        "Expected #{@fail_args[0].inspect} to not exist."
      ].join("\n")
      @fail_message = @test.fail_results.first.message
    end
    subject{ @fail_message }

    should "have a fail message with an explanation of what failed and my fail description" do
      assert_equal @expected, subject
    end

  end

end