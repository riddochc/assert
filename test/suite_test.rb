require 'assert'

require 'assert/suite'
require 'assert/context'
require 'assert/test'
require 'test/fixtures/inherited_stuff'
require 'test/fixtures/sample_context'


class Assert::Suite

  class BasicTest < Assert::Context
    desc "an basic suite"
    setup do
      @suite = Assert::Suite.new
    end
    subject { @suite }

    INSTANCE_METHODS = [
      :start_time, :end_time, :start_time=, :end_time=,
      :<<,
      :contexts, :tests, :ordered_tests, :ordered_results,
      :count, :test_count, :result_count,
      :run_time
    ]
    INSTANCE_METHODS.each do |method|
      should "respond to the instance method ##{method}" do
        assert_respond_to subject, method
      end
    end

    should "be a hash" do
      assert_kind_of ::Hash, subject
    end

    should "push contexts on itself" do
      context_class = Factory.context_class
      subject << context_class
      assert_equal true, subject.has_key?(context_class)
      assert_equal [], subject[context_class]
    end

    should "determine a klass' local public test methods" do
      assert_equal(
        ["test_subclass_stuff", "test_mixin_stuff"].sort,
        subject.send(:local_public_test_methods, SubStuff).sort
      )
    end

    should "have zero run time by default" do
      assert_equal 0, subject.run_time
    end

  end

  class WithTestsTest < Assert::Context
    desc "a suite with tests"
    setup do
      @suite = Assert::Suite.new
      context_class = Factory.context_class
      @suite[context_class] = [
        Factory.test("should do nothing", context_class),
        Factory.test("should pass", context_class) do
          assert(1==1)
          refute(1==0)
        end,
        Factory.test("should fail", context_class) do
          ignore
          assert(1==0)
          refute(1==1)
        end,
        Factory.test("should be ignored", context_class) do
          ignore
        end,
        Factory.test("should skip", context_class) do
          skip
          ignore
          assert(1==1)
        end,
        Factory.test("should error", context_class) do
          raise Exception
          ignore
          assert(1==1)
        end
      ]
      @suite.tests.each(&:run)
    end
    subject{ @suite }

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

  end

  class CountTest < WithTestsTest

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


  class TestsTest < WithTestsTest

    should "build test instances to run" do
      assert_kind_of Assert::Test, subject.tests.first
    end

  end


  class PrepTest < Assert::Context
    desc "a suite with a context with local public test meths"
    setup do
      @suite = Assert::Suite.new
      @suite << TwoTests
    end
    subject{ @suite }

    should "create tests from any local public test methods with a prep call" do
      subject.send(:prep)
      assert_equal 2, subject.test_count(TwoTests)
    end

    should "not double count local public test methods with multiple prep calls" do
      subject.send(:prep)
      subject.send(:prep)
      assert_equal 2, subject.test_count(TwoTests)
    end

    should "create tests from any local public test methods with a test_count call" do
      assert_equal 2, subject.test_count(TwoTests)
    end

  end

end
