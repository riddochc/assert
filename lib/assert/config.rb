require 'assert/default_runner'
require 'assert/default_suite'
require 'assert/default_view'
require 'assert/utils'

module Assert

  class Config

    def self.settings(*items)
      items.each do |item|
        define_method(item) do |*args|
          if !(value = args.size > 1 ? args : args.first).nil?
            instance_variable_set("@#{item}", value)
          end
          instance_variable_get("@#{item}")
        end
      end
    end

    settings :view, :suite, :runner
    settings :test_dir, :test_helper, :test_file_suffixes
    settings :changed_proc, :pp_proc, :use_diff_proc, :run_diff_proc
    settings :runner_seed, :changed_only, :changed_ref, :pp_objects
    settings :capture_output, :halt_on_fail, :profile, :verbose, :list, :debug

    def initialize(settings = nil)
      @view   = Assert::DefaultView.new(self, $stdout)
      @suite  = Assert::DefaultSuite.new(self)
      @runner = Assert::DefaultRunner.new(self)

      @test_dir    = "test"
      @test_helper = "helper.rb"
      @test_file_suffixes = ['_tests.rb', '_test.rb']

      @changed_proc  = Assert::U.git_changed_proc
      @pp_proc       = Assert::U.stdlib_pp_proc
      @use_diff_proc = Assert::U.default_use_diff_proc
      @run_diff_proc = Assert::U.syscmd_diff_proc

      # option settings
      @runner_seed    = begin; srand; srand % 0xFFFF; end.to_i
      @changed_only   = false
      @changed_ref    = ''
      @pp_objects     = false
      @capture_output = false
      @halt_on_fail   = true
      @profile        = false
      @verbose        = false
      @list           = false
      @debug          = false

      self.apply(settings || {})
    end

    def apply(settings)
      settings.keys.each do |name|
        if !settings[name].nil? && self.respond_to?(name.to_s)
          self.send(name.to_s, settings[name])
        end
      end
    end

  end

end
