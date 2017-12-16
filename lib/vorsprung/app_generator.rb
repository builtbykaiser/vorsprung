module Vorsprung
  class AppGenerator < Rails::Generators::AppGenerator
    def source_paths
      [
        Vorsprung.templates_root, # this needs to come first so these templates are preferred
        Rails::Generators::AppGenerator.source_root
      ]
    end
  end
end
