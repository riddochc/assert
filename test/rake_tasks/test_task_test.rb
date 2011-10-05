require 'assert'

require 'assert/rake_tasks/test_task'

module Assert::RakeTasks

  class TestTaskTests < Assert::Context
    desc "the test task"
    setup do
      @task = Assert::RakeTasks::TestTask.new('thing')
      @some_thing = Assert::RakeTasks::TestTask.new('test/some/thing')
    end
    subject { @task }

    should have_accessors :path, :files
    should have_instance_methods :relative_path, :scope_description, :description, :name
    should have_instance_methods :file_list, :ruby_args, :show_loaded_files?

    should "default with empty files collection" do
      assert_equal [], subject.files
    end

    should "know its relative path" do
      assert_equal "", subject.relative_path
      assert_equal "some/thing", @some_thing.relative_path
    end

    should "know its scope description" do
      assert_equal "", subject.scope_description
      assert_equal " for some/thing", @some_thing.scope_description
    end

    should "know its task description" do
      assert_equal "Run all tests", subject.description
      assert_equal "Run all tests for some/thing", @some_thing.description
    end

    should "know its name" do
      assert_equal :thing, @task.name
      assert_equal :thing, @some_thing.name
    end

    should "build a file list string" do
      subject.files = ["test_one_test.rb", "test_two_test.rb"]
      assert_equal "\"test_one_test.rb\" \"test_two_test.rb\"", subject.file_list
    end

    should "know its ruby args" do
      subject.files = ["test_one_test.rb", "test_two_test.rb"]
      assert_equal "-rrubygems \"#{subject.send(:rake_loader)}\" #{subject.file_list}", subject.ruby_args
    end

  end

  class VerboseTests < TestTaskTests
    setup do
      @orig_env_setting = ENV["show_loaded_files"]
      ENV["show_loaded_files"] = 'false'
    end
    teardown do
      ENV["show_loaded_files"] = @orig_env_setting
    end

    should "not show loaded files by default" do
      assert_equal false, subject.show_loaded_files?
    end
  end

  class EnvVerboseTests < VerboseTests
    desc "if the show_loaded_files env setting is true"
    setup do
      ENV["show_loaded_files"] = 'true'
    end

    should "show loaded files" do
      assert_equal true, subject.show_loaded_files?
    end
  end

end