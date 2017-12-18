require "rails/generators/rails/app/app_generator"
require "vorsprung/version"
require "vorsprung/app_builder"
require "vorsprung/app_generator"

module Vorsprung
  def self.templates_root
    File.expand_path('../templates', __dir__)
  end
end
