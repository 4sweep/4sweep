require 'open3'
require 'pegjs/execution_error'
require 'pegjs/version'

module Pegjs
  class << self
    def version
      Version.from_string `pegjs --version`
    end

    def parse(grammar, opts = {})
      defaultOpts = {:exportvar => 'module.exports', :allowedStartRules => ""}
      options = defaultOpts.merge(opts)
      if (options[:allowedStartRules].size > 0)
        allowedStartRules = "--allowed-start-rules " + options[:allowedStartRules]
      end
      stdout, stderr, status = Open3.capture3("pegjs -e #{options[:exportvar]} #{allowedStartRules}", :stdin_data => grammar)
      throw stderr unless status.exitstatus.zero?
      return stdout if status.exitstatus.zero?
      raise ExecutionError.new(stderr, status.exitstatus)
    end
  end
end
