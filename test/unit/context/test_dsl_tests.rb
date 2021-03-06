require 'assert'
require 'assert/context/test_dsl'

module Assert::Context::TestDSL

  class UnitTests < Assert::Context
    desc "Assert::Context::TestDSL"
    setup do
      @test_desc = "be true"
      @test_block = ::Proc.new{ assert(true) }
    end

    should "build a test using `test` with a desc and code block" do
      d, b = @test_desc, @test_block
      context_class = Factory.modes_off_context_class{ test(d, &b) }

      assert_equal 1, context_class.suite.tests.size

      exp_test_name = @test_desc
      built_test    = context_class.suite.tests.first

      assert_kind_of Assert::Test, built_test
      assert_equal exp_test_name, built_test.name
      assert_equal @test_block,   built_test.code
    end

    should "build a test using `should` with a desc and code block" do
      d, b = @test_desc, @test_block
      context_class = Factory.modes_off_context_class{ should(d, &b) }

      assert_equal 1, context_class.suite.tests.size

      exp_test_name = "should #{@test_desc}"
      built_test    = context_class.suite.tests.last

      assert_kind_of Assert::Test, built_test
      assert_equal exp_test_name, built_test.name
      assert_equal @test_block,   built_test.code
    end

    should "build a test that skips with no msg when `test_eventually` called" do
      d, b = @test_desc, @test_block
      context = build_eval_context{ test_eventually(d, &b) }
      err = capture_err(Assert::Result::TestSkipped) do
        context.instance_eval(&context.class.suite.tests.last.code)
      end

      assert_equal 1,      context.class.suite.tests.size
      assert_equal 'TODO', err.message
      assert_equal 1,      err.backtrace.size
    end

    should "build a test that skips with no msg  when `should_eventually` called" do
      d, b = @test_desc, @test_block
      context = build_eval_context{ should_eventually(d, &b) }
      err = capture_err(Assert::Result::TestSkipped) do
        context.instance_eval(&context.class.suite.tests.last.code)
      end

      assert_equal 1,      context.class.suite.tests.size
      assert_equal 'TODO', err.message
      assert_equal 1,      err.backtrace.size
    end

    should "skip with the msg \"TODO\" when `test` called with no block" do
      d = @test_desc
      context = build_eval_context { test(d) } # no block passed
      err = capture_err(Assert::Result::TestSkipped) do
        context.instance_eval(&context.class.suite.tests.last.code)
      end

      assert_equal 1,      context.class.suite.tests.size
      assert_equal 'TODO', err.message
      assert_equal 1,      err.backtrace.size
    end

    should "skip with the msg \"TODO\" when `should` called with no block" do
      d = @test_desc
      context = build_eval_context { should(d) } # no block passed
      err = capture_err(Assert::Result::TestSkipped) do
        context.instance_eval(&context.class.suite.tests.last.code)
      end

      assert_equal 1,      context.class.suite.tests.size
      assert_equal 'TODO', err.message
      assert_equal 1,      err.backtrace.size
    end

    should "skip with the msg \"TODO\" when `test_eventually` called with no block" do
      d = @test_desc
      context = build_eval_context{ test_eventually(d) } # no block given
      err = capture_err(Assert::Result::TestSkipped) do
        context.instance_eval(&context.class.suite.tests.last.code)
      end

      assert_equal 1,      context.class.suite.tests.size
      assert_equal 'TODO', err.message
      assert_equal 1,      err.backtrace.size
    end

    should "skip with the msg \"TODO\" when `should_eventually` called with no block" do
      d = @test_desc
      context = build_eval_context{ should_eventually(d) } # no block given
      err = capture_err(Assert::Result::TestSkipped) do
        context.instance_eval(&context.class.suite.tests.last.code)
      end

      assert_equal 1,      context.class.suite.tests.size
      assert_equal 'TODO', err.message
      assert_equal 1,      err.backtrace.size
    end

    should "build a test from a macro using `test`" do
      d, b = @test_desc, @test_block
      m = Assert::Macro.new{ test(d, &b); test(d, &b) }
      context_class = Factory.modes_off_context_class{ test(m) }

      assert_equal 2, context_class.suite.tests.size
    end

    should "build a test from a macro using `should`" do
      d, b = @test_desc, @test_block
      m = Assert::Macro.new{ should(d, &b); should(d, &b) }
      context_class = Factory.modes_off_context_class{ should(m) }

      assert_equal 2, context_class.suite.tests.size
    end

    should "build a test that skips from a macro using `test_eventually`" do
      d, b = @test_desc, @test_block
      m = Assert::Macro.new{ test(d, &b); test(d, &b) }
      context = build_eval_context{ test_eventually(m) }

      assert_equal 1, context.class.suite.tests.size
      assert_raises(Assert::Result::TestSkipped) do
        context.instance_eval(&context.class.suite.tests.last.code)
      end
    end

    should "build a test that skips from a macro using `should_eventually`" do
      d, b = @test_desc, @test_block
      m = Assert::Macro.new{ should(d, &b); should(d, &b) }
      context = build_eval_context{ should_eventually(m) }

      assert_equal 1, context.class.suite.tests.size
      assert_raises(Assert::Result::TestSkipped) do
        context.instance_eval(&context.class.suite.tests.last.code)
      end

    end

    private

    def build_eval_context(&build_block)
      context_class = Factory.modes_off_context_class &build_block
      context_info  = Factory.context_info(context_class)
      test = Factory.test("whatever", context_info)
      context_class.new(test, test.config, proc{ |r| })
    end

    def capture_err(err_class, &block)
      begin
        block.call
      rescue err_class => e
        e
      end
    end

  end

end
