require 'assert'
require 'assert/config'

require 'assert/default_suite'
require 'assert/default_view'
require 'assert/runner'

class Assert::Config

  class UnitTests < Assert::Context
    desc "Assert::Config"
    setup do
      @config = Assert::Config.new
    end
    subject{ @config }

    should have_imeths :view, :suite, :runner
    should have_imeths :test_dir, :test_helper, :test_file_suffixes
    should have_imeths :changed_proc, :pp_proc, :use_diff_proc, :run_diff_proc
    should have_imeths :runner_seed, :changed_only, :changed_ref, :pp_objects
    should have_imeths :capture_output, :halt_on_fail, :profile, :verbose, :list
    should have_imeths :debug, :apply

    should "default the view, suite, and runner" do
      assert_kind_of Assert::DefaultView,   subject.view
      assert_kind_of Assert::DefaultSuite,  subject.suite
      assert_kind_of Assert::DefaultRunner, subject.runner
    end

    should "default the test dir/helper/suffixes" do
      assert_equal 'test',                    subject.test_dir
      assert_equal 'helper.rb',               subject.test_helper
      assert_equal ['_tests.rb', "_test.rb"], subject.test_file_suffixes
    end

    should "default the procs" do
      assert_not_nil subject.changed_proc
      assert_not_nil subject.pp_proc
      assert_not_nil subject.use_diff_proc
      assert_not_nil subject.run_diff_proc
    end

    should "default the option settings" do
      assert_not_nil subject.runner_seed
      assert_not     subject.changed_only
      assert_empty   subject.changed_ref
      assert_not     subject.pp_objects
      assert_not     subject.capture_output
      assert         subject.halt_on_fail
      assert_not     subject.profile
      assert_not     subject.verbose
      assert_not     subject.list
      assert_not     subject.debug
    end

    should "apply settings given from a hash" do
      assert subject.halt_on_fail
      subject.apply(:halt_on_fail => false)
      assert_not subject.halt_on_fail

      assert Assert::Config.new.halt_on_fail
      assert_not Assert::Config.new(:halt_on_fail => false).halt_on_fail
    end

  end

end
