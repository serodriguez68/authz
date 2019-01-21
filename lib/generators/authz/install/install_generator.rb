module Authz
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def copy_initializer_file
        copy_file 'initializer.rb', 'config/initializers/authz.rb'
      end

      def copy_migrations
        rake('authz:install:migrations')
      end

    end
  end
end


