module Pegjs
  class ExecutionError < RuntimeError
    attr_reader :exit_code

    def initialize(message, exit_code)
      super(message)
      @exit_code = exit_code
    end
  end
end
