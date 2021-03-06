require 'assert'
require 'assert/runner'

require 'stringio'
require 'assert/config_helpers'
require 'assert/default_suite'
require 'assert/result'
require 'assert/view'

class Assert::Runner

  class UnitTests < Assert::Context
    desc "Assert::Runner"
    subject{ Assert::Runner }

    should "include the config helpers" do
      assert_includes Assert::ConfigHelpers, subject
    end

  end

  class InitTests < UnitTests
    desc "when init"
    setup do
      @config = Factory.modes_off_config
      @config.suite Assert::DefaultSuite.new(@config)
      @config.view  Assert::View.new(@config, StringIO.new("", "w+"))

      @runner = Assert::Runner.new(@config)
    end
    subject { @runner }

    should have_readers :config, :suite, :view
    should have_imeths :run, :run!
    should have_imeths :before_load, :after_load
    should have_imeths :on_start, :on_finish, :on_interrupt
    should have_imeths :before_test, :after_test, :on_result

    should "know its config" do
      assert_equal @config, subject.config
    end

    should "not have set its suite and view" do
      assert_nil subject.suite
      assert_nil subject.view
    end

  end

  class RunTests < InitTests
    desc "and run"
    setup do
      callback_mixin = Module.new
      runner_class = Class.new(Assert::Runner) do
        include CallbackMixin

        def run!(&block)
          self.suite.tests.each(&block)
        end
      end
      suite_class  = Class.new(Assert::DefaultSuite){ include CallbackMixin }
      view_class   = Class.new(Assert::View){ include CallbackMixin }

      @config.suite suite_class.new(@config)
      @config.view  view_class.new(@config, StringIO.new("", "w+"))

      ci = Factory.context_info(Factory.modes_off_context_class)
      @test = Factory.test("should pass", ci){ assert(1==1) }
      @config.suite.tests << @test

      @runner = runner_class.new(@config)
      @result = @runner.run
    end

    should "return an integer exit code" do
      assert_equal 0, @result
    end

    should "have set its suite and view" do
      assert_equal @config.suite, subject.suite
      assert_equal @config.view,  subject.view
    end

    should "run all callback on itself, the suite and the view" do
      # itself
      assert_true subject.on_start_called
      assert_equal @test, subject.before_test_called
      assert_instance_of Assert::Result::Pass, subject.on_result_called
      assert_equal @test, subject.after_test_called
      assert_true subject.on_finish_called

      # suite
      suite = @config.suite
      assert_true suite.on_start_called
      assert_equal @test, suite.before_test_called
      assert_instance_of Assert::Result::Pass, suite.on_result_called
      assert_equal @test, suite.after_test_called
      assert_true suite.on_finish_called

      # view
      view = @config.view
      assert_true view.on_start_called
      assert_equal @test, view.before_test_called
      assert_instance_of Assert::Result::Pass, view.on_result_called
      assert_equal @test, view.after_test_called
      assert_true view.on_finish_called
    end

  end

  module CallbackMixin
    attr_reader :on_start_called, :on_finish_called
    attr_reader :before_test_called, :after_test_called, :on_result_called

    def on_start;          @on_start_called     = true;   end
    def before_test(test); @before_test_called  = test;   end
    def on_result(result); @on_result_called    = result; end
    def after_test(test);  @after_test_called   = test;   end
    def on_finish;         @on_finish_called    = true;   end
  end

end
