require 'assert'
require 'assert/suite'
require 'assert/test'
require 'test/support/inherited_stuff'

class Assert::Suite

  class BasicTests < Assert::Context
    desc "an basic suite"
    setup do
      @suite = Assert::Suite.new
    end
    subject{ @suite }

    should have_imeths :ordered_tests, :results, :ordered_results, :run_time
    should have_imeths :count, :test_count, :result_count
    should have_imeths :setup, :startup, :teardown, :shutdown
    should have_accessors :tests, :test_methods, :start_time, :end_time

    should "determine a klass' local public test methods" do
      exp = ["test_subclass_stuff", "test_mixin_stuff", "test_repeated"].sort
      act = subject.send(:local_public_test_methods, SubStuff).sort.map(&:to_s)
      assert_equal(exp, act)
    end

    should "have zero a run time by default" do
      assert_equal 0, subject.run_time
    end

  end

  class WithTestsTests < Assert::Context
    desc "a suite with tests"
    setup do
      ci = Factory.context_info(Factory.context_class)
      @suite = Assert::Suite.new
      @suite.tests = [
        Factory.test("should nothing", ci){ },
        Factory.test("should pass",    ci){ assert(1==1); refute(1==0) },
        Factory.test("should fail",    ci){ ignore; assert(1==0); refute(1==1) },
        Factory.test("should ignored", ci){ ignore },
        Factory.test("should skip",    ci){ skip; ignore; assert(1==1) },
        Factory.test("should error",   ci){ raise Exception; ignore; assert(1==1) }
      ]
      @suite.tests.each(&:run)
    end
    subject{ @suite }

    should "build test instances to run" do
      assert_kind_of Assert::Test, subject.tests.first
    end

    should "know how many tests it has" do
      assert_equal 6, subject.test_count
    end

    should "know its ordered tests" do
      assert_equal subject.test_count, subject.ordered_tests.size
    end

    should "know how many results it has" do
      assert_equal 8, subject.result_count
    end

    should "know its ordered results" do
      assert_equal subject.test_count, subject.ordered_tests.size
    end

    should "know how many pass results it has" do
      assert_equal 2, subject.result_count(:pass)
    end

    should "know how many fail results it has" do
      assert_equal 2, subject.result_count(:fail)
    end

    should "know how many ignore results it has" do
      assert_equal 2, subject.result_count(:ignore)
    end

    should "know how many skip results it has" do
      assert_equal 1, subject.result_count(:skip)
    end

    should "know how many error results it has" do
      assert_equal 1, subject.result_count(:error)
    end

    should "count its tests" do
      assert_equal subject.test_count, subject.count(:tests)
    end

    should "count its results" do
      assert_equal subject.result_count, subject.count(:results)
    end

    should "count its passed results" do
      assert_equal subject.result_count(:pass), subject.count(:passed)
      assert_equal subject.result_count(:pass), subject.count(:pass)
    end

    should "count its failed results" do
      assert_equal subject.result_count(:fail), subject.count(:failed)
      assert_equal subject.result_count(:fail), subject.count(:fail)
    end

    should "count its ignored results" do
      assert_equal subject.result_count(:ignore), subject.count(:ignored)
      assert_equal subject.result_count(:ignore), subject.count(:ignore)
    end

    should "count its skipped results" do
      assert_equal subject.result_count(:skip), subject.count(:skipped)
      assert_equal subject.result_count(:skip), subject.count(:skip)
    end

    should "count its errored results" do
      assert_equal subject.result_count(:error), subject.count(:errored)
      assert_equal subject.result_count(:error), subject.count(:error)
    end

  end

  class SetupTests < Assert::Context
    desc "a suite with a setup block"
    setup do
      @setup_status = nil
      @suite = Assert::Suite.new
      @setup_blocks = []
      @setup_blocks << ::Proc.new{ @setup_status = "setup" }
      @setup_blocks << ::Proc.new{ @setup_status += " has been run" }
      @setup_blocks.each{ |setup_block| @suite.setup(&setup_block) }
    end
    subject{ @setup_status }

    should "set the setup status to the correct message" do
      @suite.setup
      assert_equal "setup has been run", subject
    end

    should "return the setup blocks with the #setups method" do
      setups = @suite.send(:setups)
      @setup_blocks.each do |setup_block|
        assert_includes setup_block, setups
      end
    end

  end

  class TeardownTests < Assert::Context
    desc "a suite with a teardown"
    setup do
      @teardown_status = nil
      @suite = Assert::Suite.new
      @teardown_blocks = []
      @teardown_blocks << ::Proc.new{ @teardown_status += " has been run" }
      @teardown_blocks << ::Proc.new{ @teardown_status = "teardown" }
      @teardown_blocks.each{ |teardown_block| @suite.teardown(&teardown_block) }
    end

    should "set the teardown status to the correct message" do
      @suite.teardown
      assert_equal "teardown has been run", @teardown_status
    end

    should "return the teardown blocks with the #teardowns method" do
      teardowns = @suite.send(:teardowns)
      @teardown_blocks.each do |setup_block|
        assert_includes setup_block, teardowns
      end
    end

  end

  class ContextInfoTests < Assert::Context
    desc "a suite's context info"
    setup do
      @caller = caller
      @klass  = Assert::Context
      @info   = Assert::Suite::ContextInfo.new(@klass, nil, @caller.first)
    end
    subject{ @info }

    should have_readers :called_from, :first_caller, :klass, :file

    should "set its klass on init" do
      assert_equal @klass, subject.klass
    end

    should "set its called_from to the first caller on init" do
      assert_equal @caller.first, subject.first_caller
    end

    should "set its file from caller info on init" do
      assert_equal @caller.first.gsub(/\:[0-9]+.*$/, ''), subject.file
    end

    should "not have any file info if no caller is given" do
      info = Assert::Suite::ContextInfo.new(@klass)
      assert_nil info.file
    end

  end

end