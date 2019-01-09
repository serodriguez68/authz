module Authz
  module Scopables
    module Base

      # Scopable::Base tracks all available Scopables
      # ===================================================================
      @@scopables = [] # Contains a handle to each scopable
      def self.register_scopable(scopable)
        @@scopables << scopable unless @@scopables.include?(scopable)
      end

      # Returns an array with the names of the modules in camelcase (string)
      def self.get_scopables_names
        @@scopables.map{ |s| s.name }
      end

      # Returns an array of the scoping module instances
      def self.get_scopables_modules
        @@scopables
      end

      # Returns true if the given scopable name exists
      # as a valid scopable
      # @scopable_name: the string name of the scopable to
      #                 test
      # @return: true or false
      def self.scopable_exists?(scopable_name)
        get_scopables_names.include?(scopable_name.to_s)
      end

      # Returns true if the given collection_or_class
      # is scopable by the given scopable module
      def self.scopable_by? collection_or_class, scopable
        collection_or_class.respond_to?(scopable.association_method_name)
      end

      # Returns all the applicable scopable modules for
      # the given collection_or_class
      def self.get_applicable_scopables collection_or_class
        get_scopables_modules.select do |scopable|
          scopable_by?(collection_or_class, scopable)
        end
      end

      # Returns all the applicable scopable modules for
      # the given collection_or_class and raises an
      # error if none are found
      def self.get_applicable_scopables! collection_or_class
        app_scopables = get_applicable_scopables(collection_or_class)
        return app_scopables if app_scopables.any?
        raise NoApplicableScopables, scoped_class: collection_or_class
      end

      # Returns an array with the special keywords
      def self.special_keywords
        [:all]
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

      # Error that will be raised if the association of a model being scoped
      # does not return the expected type of objects
      class MisconfiguredAssociation < StandardError
        attr_reader :scoped_class, :scopable, :association_method

        def initialize(options = {})
          @scoped_class  = options.fetch(:scoped_class)
          @scopable = options.fetch :scopable
          @association_method = options.fetch :association_method
          message = "#{scoped_class} has a misconfigured association " \
                     "for #{scopable}. " \
                     "Make sure that ##{association_method} " \
                     'returns either an instance of class' \
                     "#{scopable.scoping_class_name} " \
                     'or a collection that responds to #pluck(:id).'
          super(message)
        end
      end

      class NoApplicableScopables < StandardError
        attr_reader :scoped_class

        def initialize(options = {})
          @scoped_class  = options.fetch(:scoped_class)
          message = "#{scoped_class} has no applicable scopables. " \
                     'Make sure you include the scopables modules ' \
                     'inside the class definition.'
          super(message)
        end
      end

      # TODO: Add an error UnresolvableKeyword when a random given keyword
      # is given and cannot be resolved (this may require adding a method)
      # safe_resolve_keyword that internally calls resolve_keyword and
      # inspects it's return value to check that it is a valid return value


      # Scopables that extend Scopable::Base get this behaviour
      # ===================================================================
      # == Infer Naming

      # Returns the string name of the class used to scope
      def scoping_class_name
        self.to_s.remove('ScopableBy')
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
      # Eg: "scopable_by_city_association_name"
      def association_method_name
        "scopable_by_#{scoping_class_name.underscore}_association_name"
      end

      # Returns the mame of the method used to apply the scopable
      # keyword on the scoped class
      def apply_scopable_method_name
        "apply_#{to_s.underscore}"
      end

      # == Keywords

      # Returns true if the given keyword is valid
      # @param keyword: keyword being tested
      def valid_keyword?(keyword)
        available_keywords.include?(keyword)
      end

      # Normalizes the keyword if it is a
      # special keyword
      def normalize_if_special_keyword(keyword)
        norm = keyword.downcase.to_sym
        Authz::Scopables::Base.special_keywords.include?(norm) ? norm : keyword
      end

      # == Resolution
      # Returns true if the given instance_to_check is within the
      # scoping privileges of the given keyword, optionally passing
      # the requester to aide the resolution of the keyword.
      def within_scope_of_keyword?(instance_to_check, keyword, requester)
        keyword = normalize_if_special_keyword(keyword)
        # Shortcut treatment for special keywords
        return true if keyword == :all

        instance_scope_ids = associated_scoping_instances_ids(instance_to_check)
        role_scope_ids = resolve_keyword(keyword, requester)

        # Resolution
        if instance_scope_ids.any?
          # When instance is associated to scoping class (report with city)
          # Resolve by intersection
          (instance_scope_ids & role_scope_ids).any?
        else
          # When instance is not associated to scoping class
          # (e.g report with no city, announcement not available,
          # in any city, city that has not been persisted)

          # Fix singularity problem that allowed resolved keywords
          # that include nil to consider non persisted instances
          # of scoping classes (e.g. a city that has not been saved
          # yet) within scope. (ultimately allowing the creation
          # to out of scope)
          return false if instance_to_check.class == scoping_class

          role_scope_ids.include? nil
        end
      end

      # Receives an instance of any class that is scopable
      # by this scopable and returns an array of ids of
      # the associated scoping instances.
      #
      # For example:
      # 1. Receives a report and returns an array with the
      # the id of the city associated with the report [32]
      # or [] if not associated
      # 2. Receives an announcement and returns an array with the
      # ids of the cites in which it is available [1,2,3]
      # or [] if not associated
      def associated_scoping_instances_ids(instance_to_check)
        scoped_class = instance_to_check.class
        # When the instance is an instances of the Scoping Class
        # (e.g when we are checking the associated cities of a city)
        return [instance_to_check.id] if scoped_class == scoping_class

        assoc_method = scoped_class.send(association_method_name)
        instance_scope = instance_to_check.send(assoc_method)
        # instance_scope = report.city  => a city instance / nil
        # instance_scope = announcement.cities => AR Relation of Cities / (may be empty)

        if instance_scope.class == scoping_class
          # When the instance is associated with ONE instance of the scoping class
          # (e.g report is associated with one city)
          instance_scope_ids = [instance_scope.id]

        elsif instance_scope.nil?
          # When the instance is associated with ONE instance of scoping class
          # but the association is empty (e.g. a record with no city)
          instance_scope_ids = []

        elsif instance_scope.respond_to? 'pluck'
          # When the instance is associated with MANY instances of the scoping
          # class. Even if the association is empty
          # (e.g announcement is available in many cities)
          instance_scope_ids = instance_scope.pluck(:id)

        else
          raise MisconfiguredAssociation,
                scoped_class: scoped_class,
                scopable: self,
                association_method: assoc_method
        end
        instance_scope_ids
      end

      # When Scopables::Base is extended, run within the context of the
      # extending scopable
      # ===================================================================
      def self.extended(scopable)
        # self = Authz::Scopable::Base
        # scopable = scopable module that extended

        scopable.extend ActiveSupport::Concern
        self.register_scopable(scopable)

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
          define_method scopable.apply_scopable_method_name do |keyword, requester|
            keyword = scopable.normalize_if_special_keyword(keyword)

            if self.name == scopable.scoping_class_name
              # If the scoped class is the same scoping class
              # (e.g City and ScopableByCity)

              # Treatment for special keywords
              return self.all if keyword == :all

              scoped_ids = scopable.resolve_keyword(keyword, requester)
              return self.where(id: scoped_ids)

            elsif (association_name = self.send(scopable.association_method_name))
              # If the scoped class scoped by the scoping class
              # (e.g Report and ScopableByCity) Join through the association to query

              joined_collection = self.left_outer_joins(association_name)
              # Always left_outer_joins to account for records that are not
              # associated with the scoping class (e.g. reports with no city)
              # Report.left_outer_joins(:city)

              # Treatment for special keywords
              # TODO: the collection is forced to get joined to ensure structural
              # compatibility with ActiveRecord#or
              return joined_collection.all if keyword == :all

              scoped_ids = scopable.resolve_keyword(keyword, requester)
              return joined_collection.merge(scopable.scoping_class.where(id: scoped_ids))
              # Report.joins(:city).merge(City.where(id: [1,2,3]))
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