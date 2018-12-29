module Authz
  module Scopables
    module Base

      # Scopable::Base tracks all available Scopables
      # ===================================================================
      # Returns an array with the names of the modules in camelcase (string)
      def self.get_scoping_modules_names
        file_names_with_dir = Dir["#{Authz.scopables_directory}/*"]
        module_names = file_names_with_dir.map do |fnd|
          fnd.gsub("#{Authz.scopables_directory}/",'').split('.').first.camelcase
        end
        return module_names
      end

      # Returns an array of the scoping module instances
      def self.get_scoping_modules
        self.get_scoping_modules_names.map(&:constantize)
      end

      # Errors
      # ===========================================================================
      # Error that will be raised if the model being scoped has ambiguous
      # association  names for the included scopable
      # (e.g. has both :city and :cities  associations and
      # ScopableByCity is Being included)
      class AmbiguousAssociationName < StandardError
        attr_reader :scoped_class, :scopable, :association_names

        def initialize(options = {})
          @scoped_class  = options.fetch(:scoped_class)
          @scopable = options.fetch :scopable
          @association_names = options.fetch :association_names
          message = "#{scoped_class} has ambiguous association names " \
                     "#{association_names} for #{scopable}. " \
                     'Use the ' \
                     "set_scopable_by_#{scopable.scoping_class_name.underscore}_association_name " \
                     'method to define it manually.'
          super(message)
        end
      end

      # Error that will be raised if the model being scoped doesn't appear to
      # have an association to the scoping class.
      class NoAssociationFound < StandardError
        attr_reader :scoped_class, :scopable, :scoping_class

        def initialize(options = {})
          @scoped_class  = options.fetch(:scoped_class)
          @scopable = options.fetch :scopable
          scoping_class = options.fetch :scoping_class
          message = "#{scoped_class} is not associated with " \
              "#{scoping_class} for #{scopable}. "
          super(message)
        end
      end

      # Infer Naming
      # Scopables that extend Scopable::Base get this behaviour
      # ===================================================================

      # Returns the string name of the class used to scope
      def scoping_class_name
        self.to_s.remove("ScopableBy")
      end

      # Returns the Active Record Class of the Model used to scope
      def scoping_class
        scoping_class_name.constantize
      end

      # Symbol of a singular association following Rails'conventions
      def singular_association_name
        scoping_class.model_name.singular.to_sym
      end

      # Symbol of a plural association following Rails' conventions
      def plural_association_name
        scoping_class.model_name.plural.to_sym
      end

      # Returns the name of the method used to get the name of the association
      # for this scopable.
      # Format: "scopable_by_#{scoping_class_name.underscore}_association_name"
      def association_method_name
        "scopable_by_#{scoping_class_name.underscore}_association_name"
      end

      # When Scopables::Base is exetended, run within the context of the
      # extending scopable
      # ===================================================================
      def self.extended(scopable)
        # self = Authz::Scopable::Base
        # scopable = scopable module that extended

        scopable.extend ActiveSupport::Concern

        # Any class that extends a Scopable gets these class methods
        # ===================================================================
        scopable.class_methods do
          # self = The class being scoped (the class that includes an scopable)

          # Defines a method that returns the name of the association to be used
          # for scoping.
          # For example, if Report includes ScopableByCity this will create a
          # scopable_by_city_association_name method.
          #
          # The method infers the association name to be used with the scopable.
          # If ambiguity is found, raises an Exception.
          #
          # This method should be overriden to manually set the association name.
          define_method scopable.association_method_name do
            association_name = (self.reflect_on_all_associations.map(&:name) &
                                [scopable.singular_association_name.to_sym,
                                 scopable.plural_association_name.to_sym])

            if association_name.size > 1
              raise AmbiguousAssociationName,
                    scoped_class: self.model_name.to_s,
                    scopable: scopable,
                    association_names: association_name
            end

            association_name.last

          end

          # Provides scoped classes with a convenient method to override the automatically inferred
          # association name for a given scopable.
          #
          # Usage:
          # include ScopableByCity
          # set_scopable_by_city_association_name :province
          define_method "set_#{scopable.association_method_name}" do |assoc_name|
            unless %w[Symbol String].include? assoc_name.class.name
              raise 'only strings or symbols are allowed'
            end
            define_singleton_method(scopable.association_method_name) { assoc_name.to_sym }
          end


          # Applies the scopable keyword on the class
          # @return a collection of the scoped class record after applying the scope
          define_method "apply_#{scopable.to_s.underscore}" do |keyword, requester|
            # Special treatment to keyword 'all'
            return self.all if keyword.downcase.to_sym == :all

            scoped_ids = scopable.resolve_keyword(keyword, requester)

            if self.name == scopable.scoping_class_name
              # If the scoped class is the same scoping class
              return self.where(id: scoped_ids)
            elsif (association_name = self.send(scopable.association_method_name))
              # Join through the association to query
              joined_collection = scoped_ids.nil? ? self.left_outer_joins(association_name) : self.joins(association_name)
              return joined_collection.where(
                  scopable.plural_association_name => { id: scoped_ids }
              )
            else
              raise NoAssociationFound,
                    scoped_class: self.model_name.to_s,
                    scopable: scopable,
                    scoping_class: scopable.scoping_class_name
            end
          end

        end
      end

      # Scopables must implement
      # ===================================================================
      def available_keywords
        raise NotImplementedError, "#{self}.
        All Scopables must implement a method that returns the available
        scoping keywords"
      end

      def resolve_keyword(keyword, requester)
        msg = "#{self} must implement a method " \
              ' that takes in a keyword and the requester' \
              ' (e.g. the user) and returns an array of ids of ' \
              "#{self.scoping_class_name} for that keyword"
        raise NotImplementedError, msg
      end


    end
  end
end