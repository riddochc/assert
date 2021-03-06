require 'assert'
require 'assert/view_helpers'

require 'assert/config'
require 'assert/config_helpers'
require 'assert/result'

module Assert::ViewHelpers

  class UnitTests < Assert::Context
    desc "Assert::ViewHelpers"
    setup do
      test_opt_val = @test_opt_val = Factory.string
      @helpers_class = Class.new do
        include Assert::ViewHelpers

        option 'test_opt', test_opt_val

        def config
          # use the assert config since it has tests, contexts, etc
          # also maybe use a fresh config that is empty
          @config ||= [Assert.config, Assert::Config.new].choice
        end
      end
    end
    subject{ @helpers_class }

    should have_imeths :option

    should "include the config helpers" do
      assert_includes Assert::ConfigHelpers, subject
    end

    should "write option values" do
      helpers = @helpers_class.new
      assert_equal @test_opt_val, helpers.test_opt

      new_val = Factory.integer
      helpers.test_opt new_val
      assert_equal new_val, helpers.test_opt

      other_val = Factory.integer
      helpers.test_opt new_val, other_val
      assert_equal [new_val, other_val], helpers.test_opt
    end

  end

  class InitTests < UnitTests
    desc "when init"
    setup do
      @helpers = @helpers_class.new
    end
    subject{ @helpers }

    should have_imeths :test_run_time, :test_result_rate
    should have_imeths :captured_output
    should have_imeths :test_count_statement, :result_count_statement
    should have_imeths :to_sentence
    should have_imeths :all_pass_result_summary_msg, :result_summary_msg
    should have_imeths :results_summary_sentence

    should "know a test's formatted run time and result rate" do
      test   = Factory.test
      format = '%.6f'

      exp = format % test.run_time
      assert_equal exp, subject.test_run_time(test, format)
      assert_equal exp, subject.test_run_time(test)

      exp = format % test.result_rate
      assert_equal exp, subject.test_result_rate(test, format)
      assert_equal exp, subject.test_result_rate(test)
    end

    should "know how to build captured output" do
      output = Factory.string
      exp = "--- stdout ---\n"\
            "#{output}"\
            "--------------"
      assert_equal exp, subject.captured_output(output)
    end

    should "know its test count and result count statements" do
      exp = "#{subject.count(:tests)} test#{'s' if subject.count(:tests) != 1}"
      assert_equal exp, subject.test_count_statement

      exp = "#{subject.count(:results)} result#{'s' if subject.count(:results) != 1}"
      assert_equal exp, subject.result_count_statement
    end

    should "know how to build a sentence from a list of items" do
      items = 1.times.map{ Factory.string }
      assert_equal items.first, subject.to_sentence(items)

      items = 2.times.map{ Factory.string }
      assert_equal items.join(' and '), subject.to_sentence(items)

      items = (Factory.integer(3)+2).times.map{ Factory.string }
      exp = [items[0..-2].join(", "), items.last].join(", and ")
      assert_equal exp, subject.to_sentence(items)
    end

    should "know its all pass result summary message" do
      Assert.stub(subject, :count).with(:results){ 0 }
      assert_equal "uhh...", subject.all_pass_result_summary_msg

      Assert.stub(subject, :count).with(:results){ 1 }
      assert_equal "pass", subject.all_pass_result_summary_msg

      Assert.stub(subject, :count).with(:results){ Factory.integer(10)+1 }
      assert_equal "all pass", subject.all_pass_result_summary_msg
    end

    should "know its result summary msg" do
      res_type = :pass
      Assert.stub(subject, :all_pass?){ true }
      exp = subject.all_pass_result_summary_msg
      assert_equal exp, subject.result_summary_msg(res_type)

      Assert.stub(subject, :all_pass?){ false }
      res_type = [:pass, :ignore, :fail, :skip, :error].choice
      exp = "#{subject.count(res_type)} #{res_type.to_s}"
      assert_equal exp, subject.result_summary_msg(res_type)
    end

    should "know its results summary sentence" do
      items = subject.ocurring_result_types.map do |result_sym|
        subject.result_summary_msg(result_sym)
      end
      exp = subject.to_sentence(items)
      assert_equal exp, subject.results_summary_sentence

      block = proc{ |summary, result| "#{summary}--#{result}" }
      items = subject.ocurring_result_types.map do |result_sym|
        block.call(subject.result_summary_msg(result_sym), result_sym)
      end
      exp = subject.to_sentence(items)
      assert_equal exp, subject.results_summary_sentence(&block)
    end

  end

  class AnsiTests < UnitTests
    desc "Ansi"
    subject{ Ansi }

    should have_imeths :code_for

    should "know its codes" do
      assert_not_empty subject::CODES
    end

    should "map its code style names to ansi code strings" do
      styles = Factory.integer(3).times.map{ subject::CODES.keys.choice }
      exp = styles.map{ |n| "\e[#{subject::CODES[n]}m" }.join('')
      assert_equal exp, subject.code_for(*styles)

      styles = Factory.integer(3).times.map{ Factory.string }
      assert_equal '', subject.code_for(*styles)

      styles = []
      assert_equal '', subject.code_for(*styles)
    end

  end

end
