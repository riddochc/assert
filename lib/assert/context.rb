require 'assert/suite'
require 'assert/result'

module Assert
  class Context

    # a Context is a scope for tests to run in.  Contexts have setup and
    # teardown blocks, subjects, and descriptions.  Tests are run in the
    # scope of a Context instance.  Therefore, a Context should have
    # no base logic/methods/instance_vars.  The instance should remain
    # pure to not pollute test scopes.

    # if a class subclasses Context, add it to the suite
    def self.inherited(klass)
      Assert.suite << klass
    end

    # put all logic here to keep context instances pure for running tests
    class << self

    end

    def initialize(test)
      test.result = begin
        # TODO: setups
        if test.code.kind_of?(::Proc)
          instance_eval(&test.code)
        elsif self.respond_to?(test.code.to_s)
          self.send(test.code.to_s)
        end
        # TODO: teardowns

        raise Result::Pass
      rescue Result::Base => err
        err
      rescue Exception => err
        Result::Error.new(err)
      end
    end

  end
end