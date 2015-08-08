require 'assert'
require 'assert/runner'

require 'stringio'
require 'assert/config_helpers'
require 'assert/suite'
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

    should have_readers :config
    should have_imeths :run

    should "know its config" do
      assert_equal @config, subject.config
    end

    should "return an integer exit code" do
      assert_equal 0, subject.run
    end

  end

end
