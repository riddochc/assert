require 'assert/result_set'

module Assert
  class Test

    # a Test is some code/method to run in the scope of a Context.  After a
    # a test runs, it should have some assertions which are its results.

    attr_reader :name, :code, :context
    attr_accessor :results

    def initialize(name, code, context)
      @context = context
      @name = name_from_context(name)
      @code = code
      @results = ResultSet.new
    end

    def run(view=nil)
      @results.view = view
      begin
        run_scope = @context.new(self)
        run_setup(run_scope)
        if @code.kind_of?(::Proc)
          run_scope.instance_eval(&@code)
        elsif run_scope.respond_to?(@code.to_s)
          run_scope.send(@code.to_s)
        end
      rescue Result::TestSkipped => err
        @results << Result::Skip.new(self.name, err)
      rescue Exception => err
        @results << Result::Error.new(self.name, err)
      ensure
        begin
          run_teardown(run_scope) if run_scope
        rescue Exception => teardown_err
          @results << Result::Error.new(self.name, teardown_err)
        end
      end
      @results.view = nil
      @results
    end

    def run_setup(scope)
      @context._assert_setups.each do |setup|
        scope.instance_eval(&setup)
      end
    end

    def run_teardown(scope)
      @context._assert_teardowns.each do |teardown|
        scope.instance_eval(&teardown)
      end
    end

    def fail_results
      @results.select{|r| r.kind_of?(Result::Fail) }
    end

    def error_results
      @results.select{|r| r.kind_of?(Result::Error) }
    end

    def result_count(type=nil)
      case type
      when :pass
        @results.select{|r| r.kind_of?(Result::Pass)}.size
      when :fail
        fail_results.size
      when :skip
        @results.select{|r| r.kind_of?(Result::Skip)}.size
      when :error
        error_results.size
      else
        @results.size
      end
    end

    def <=>(other_test)
      self.name <=> other_test.name
    end

    protected

    def name_from_context(name)
      (@context._assert_descs + [ name ]).join(" ")
    end

  end
end
