require 'assert'

class RunningTheTestsTests < Assert::Context
  desc "Assert tests that are run"
  subject{ @test }

  class NothingTests < RunningTheTestsTests
    desc "and does nothing"
    setup do
      @test = Factory.test
      @test.run
    end

    should "have 0 results" do
      assert_equal 0, subject.result_count
    end

  end

  class PassTests < RunningTheTestsTests
    desc "and passes a single assertion"
    setup do
      @test = Factory.test{ assert(1 == 1) }
      @test.run
    end

    should "have 1 result" do
      assert_equal 1, subject.result_count
    end
    should "have 1 pass result" do
      assert_equal 1, subject.result_count(:pass)
    end

  end

  class FailTests < RunningTheTestsTests
    desc "and fails a single assertion"
    setup do
      @test = Factory.test{ assert(1 == 0) }
      @test.run
    end

    should "have 1 result" do
      assert_equal 1, subject.result_count
    end
    should "have 1 fail result" do
      assert_equal 1, subject.result_count(:fail)
    end

  end

  class SkipTests < RunningTheTestsTests
    desc "and skips"
    setup do
      @test = Factory.test{ skip }
      @test.run
    end

    should "have 1 result" do
      assert_equal 1, subject.result_count
    end
    should "have 1 skip result" do
      assert_equal 1, subject.result_count(:skip)
    end

  end

  class ErrorTests < RunningTheTestsTests
    desc "and errors"
    setup do
      @test = Factory.test{ raise("WHAT") }
      @test.run
    end

    should "have 1 result" do
      assert_equal 1, subject.result_count
    end
    should "have 1 error result" do
      assert_equal 1, subject.result_count(:error)
    end

  end

  class MixedTests < RunningTheTestsTests
    desc "and has 1 pass and 1 fail assertion"
    setup do
      @test = Factory.test do
        assert(1 == 1)
        assert(1 == 0)
      end
      @test.run
    end

    should "have 2 total results" do
      assert_equal 2, subject.result_count
    end
    should "have 1 pass result" do
      assert_equal 1, subject.result_count(:pass)
    end
    should "have 1 fail result" do
      assert_equal 1, subject.result_count(:fail)
    end

  end

  class MixedSkipTests < RunningTheTestsTests
    desc "and has 1 pass and 1 fail assertion with a skip call in between"
    setup do
      @test = Factory.test do
        assert(1 == 1)
        skip
        assert(1 == 0)
      end
      @test.run
    end

    should "have 2 total results" do
      assert_equal 2, subject.result_count
    end
    should "have a skip for its last result" do
      assert_kind_of Assert::Result::Skip, subject.results.last
    end
    should "have 1 pass result" do
      assert_equal 1, subject.result_count(:pass)
    end
    should "have 1 skip result" do
      assert_equal 1, subject.result_count(:skip)
    end
    should "have 0 fail results" do
      assert_equal 0, subject.result_count(:fail)
    end

  end

  class MixedErrorTests < RunningTheTestsTests
    desc "and has 1 pass and 1 fail assertion with an exception raised in between"
    setup do
      @test = Factory.test do
        assert(1 == 1)
        raise Exception, "something errored"
        assert(1 == 0)
      end
      @test.run
    end

    should "have an error for its last result" do
      assert_kind_of Assert::Result::Error, subject.results.last
    end
    should "have 2 total results" do
      assert_equal 2, subject.result_count
    end
    should "have 1 pass result" do
      assert_equal 1, subject.result_count(:pass)
    end
    should "have 1 error result" do
      assert_equal 1, subject.result_count(:error)
    end
    should "have 0 fail results" do
      assert_equal 0, subject.result_count(:fail)
    end

  end

  class MixedPassTests < RunningTheTestsTests
    desc "and has 1 pass and 1 fail assertion with a pass call in between"
    setup do
      @test = Factory.test do
        assert(1 == 1)
        pass
        assert(1 == 0)
      end
      @test.run
    end

    should "have a pass for its last result" do
      assert_kind_of Assert::Result::Fail, subject.results.last
    end
    should "have 3 total results" do
      assert_equal 3, subject.result_count
    end
    should "have 2 pass results" do
      assert_equal 2, subject.result_count(:pass)
    end
    should "have 1 fail results" do
      assert_equal 1, subject.result_count(:fail)
    end

  end

  class MixedFailTests < RunningTheTestsTests
    desc "and has 1 pass and 1 fail assertion with a fail call in between"
    setup do
      @test = Factory.test do
        assert(1 == 0)
        fail
        assert(1 == 1)
      end
      @test.run
    end

    should "have a fail for its last result" do
      assert_kind_of Assert::Result::Pass, subject.results.last
    end
    should "have 3 total results" do
      assert_equal 3, subject.result_count
    end
    should "have 1 pass results" do
      assert_equal 1, subject.result_count(:pass)
    end
    should "have 2 fail results" do
      assert_equal 2, subject.result_count(:fail)
    end

  end

  class MixedFlunkTests < RunningTheTestsTests
    desc "and has 1 pass and 1 fail assertion with a flunk call in between"
    setup do
      @test = Factory.test do
        assert(1 == 0)
        flunk
        assert(1 == 1)
      end
      @test.run
    end

    should "have a fail for its last result" do
      assert_kind_of Assert::Result::Pass, subject.results.last
    end
    should "have 3 total results" do
      assert_equal 3, subject.result_count
    end
    should "have 1 pass results" do
      assert_equal 1, subject.result_count(:pass)
    end
    should "have 2 fail results" do
      assert_equal 2, subject.result_count(:fail)
    end

  end

  class WithSetupTests < RunningTheTestsTests
    desc "a Test that runs and has assertions that depend on setups"
    setup do
      assert_style_msg = @asm = "set by assert style setup"
      testunit_style_msg = @tusm = "set by test/unit style setup"
      @context_class = Factory.context_class do
        # assert style setup
        setup do
          # get msgs into test scope
          @assert_style_msg = assert_style_msg
          @testunit_style_msg = testunit_style_msg

          @setup_asm = @assert_style_msg
        end
        # classic test/unit style setup
        def setup; @setup_tusm = @testunit_style_msg; end
      end
      @test = Factory.test("something", Factory.context_info(@context_class)) do
        assert @assert_style_msg
        assert @testunit_style_msg

        @__running_test__.pass_results.first.
          instance_variable_set("@message", @setup_asm)

        @__running_test__.pass_results.last.
          instance_variable_set("@message", @setup_tusm)
      end
      @test.run
    end

    should "have a passing result for each setup type" do
      assert_equal 2, subject.result_count
      assert_equal 2, subject.result_count(:pass)
    end
    should "have run the assert style setup" do
      assert_equal @asm, subject.pass_results.first.message
    end
    should "have run the test/unit style setup" do
      assert_equal @tusm, subject.pass_results.last.message
    end

  end

  class WithTeardownTests < RunningTheTestsTests
    desc "a Test that runs and has assertions with teardowns"
    setup do
      assert_style_msg = @asm = "set by assert style teardown"
      testunit_style_msg = @tusm = "set by test/unit style teardown"
      @context_class = Factory.context_class do
        setup do
          # get msgs into test scope
          @assert_style_msg = assert_style_msg
          @testunit_style_msg = testunit_style_msg
        end
        # assert style teardown
        teardown do
          @__running_test__.pass_results.first.
            instance_variable_set("@message", @assert_style_msg)
        end
        # classic test/unit style teardown
        def teardown
          @__running_test__.pass_results.last.
            instance_variable_set("@message", @testunit_style_msg)
        end
      end
      @test = Factory.test("something amazing", Factory.context_info(@context_class)) do
        assert(true) # first pass result
        assert(true) # last pass result
      end
      @test.run
    end

    should "have a passing result for each teardown type" do
      assert_equal 2, subject.result_count
      assert_equal 2, subject.result_count(:pass)
    end
    should "have run the assert style teardown" do
      assert_equal @asm, subject.pass_results.first.message
    end
    should "have run test/unit style teardown" do
      assert_equal @tusm, subject.pass_results.last.message
    end

  end

end