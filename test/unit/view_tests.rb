require 'assert'
require 'assert/suite'
require 'assert/view/base'
require 'stringio'

class Assert::View::Base

  class UnitTests < Assert::Context
    desc "Assert::View::Base"
    setup do
      @io = StringIO.new("", "w+")
      @config = Factory.modes_off_config
      @view = Assert::View::Base.new(@io, @config, @config.suite)
    end
    subject{ @view }

    # accessors, base methods
    should have_imeths :is_tty?, :view, :config, :suite, :fire
    should have_imeths :before_load, :after_load
    should have_imeths :on_start, :on_finish, :on_interrupt
    should have_imeths :before_test, :after_test, :on_result

    # common methods
    should have_imeths :runner_seed, :count, :tests?, :all_pass?
    should have_imeths :run_time, :test_rate, :result_rate
    should have_imeths :test_run_time, :test_result_rate
    should have_imeths :suite_contexts, :ordered_suite_contexts
    should have_imeths :suite_files, :ordered_suite_files
    should have_imeths :ordered_profile_tests, :show_test_profile_info?
    should have_imeths :result_details_for, :matched_result_details_for, :show_result_details?
    should have_imeths :ocurring_result_types, :result_summary_msg
    should have_imeths :all_pass_result_summary_msg, :results_summary_sentence
    should have_imeths :test_count_statement, :result_count_statement
    should have_imeths :to_sentence

    should "default its result abbreviations" do
      assert_equal '.', subject.pass_abbrev
      assert_equal 'F', subject.fail_abbrev
      assert_equal 'I', subject.ignore_abbrev
      assert_equal 'S', subject.skip_abbrev
      assert_equal 'E', subject.error_abbrev
    end

    should "know if it is a tty" do
      assert_equal !!@io.isatty, subject.is_tty?
    end

  end

  class HandlerTests < Assert::Context
    desc "Assert::View"
    subject { Assert::View }

    should have_instance_method :require_user_view

  end

end
