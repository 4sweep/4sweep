require 'rails/engine'

module Pegjs
  class Template < ::Tilt::Template
    def prepare
      # Do any initialization here
    end

    def evaluate(scope, locals, &block)
      exportvar =  scope.logical_path.gsub(".js$", '')

      # Hack Alert -- allowedStartRules expected as a comment in pegjs file
      if (data.match("^// *allowedStartRules *= *(.*)$"))
        allowedStartRules = $1.strip()
      else
        allowedStartRules = ""
      end
      return Pegjs.parse(data, :exportvar => exportvar, :allowedStartRules => allowedStartRules)
    end
  end

  module Rails
    class Engine < ::Rails::Engine
      config.app_generators.javascript_engine :pegjs
    end
  end
end

Rails.application.assets.register_engine '.pegjs', Pegjs::Template
