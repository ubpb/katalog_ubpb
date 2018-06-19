module Skala
  class Engine < ::Rails::Engine
    isolate_namespace Skala

    # http://pivotallabs.com/leave-your-migrations-in-your-rails-engines/
    #initializer :add_skala_migrations do |app|
    #  unless app.root.to_s == root.to_s # changed because the original match check fails for us
    #    config.paths["db/migrate"].expanded.each do |expanded_path|
    #      app.config.paths["db/migrate"] << expanded_path
    #    end
    #  end
    #end
  end
end
