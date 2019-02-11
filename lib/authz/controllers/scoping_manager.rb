module Authz
  module Controllers
    # Module in charge of resolving authorization for the scoping sub-system.
    # @api private
    module ScopingManager

      # Determines if the given role has access to the given instance
      # considering all the applicable scopables and the role's
      # scoping rules.
      # @param role [Authz::Role] for which access is going to be determined
      # @param instance_to_check [Object] any model instance trying to be manipulated
      # @param authz_user [Models::Rolable] rolable that is trying to access the instance (injected dependency)
      # @return [Boolean]
      def self.has_access_to_instance?(role, instance_to_check, authz_user)
        scoped_class = instance_to_check.class
        applicable_scopables = Authz::Scopables::Base.get_applicable_scopables! scoped_class

        applicable_scopables.each do |as|
          kw = role.cached_granted_keyword_for(as)
          return false unless as.within_scope_of_keyword?(instance_to_check,
                                                          kw,
                                                          authz_user)
        end

        return true
      end

      # Applies the scopables of the given user's roles to the
      # given collection or class.
      # If the user does not contain roles, it returns an empty
      # collection.
      #
      # @param collection_or_class [ActiveRecord_Relation, Class]
      #                            the starting collection on top
      #                            of which the scoping is going to
      #                            be applied
      # @param authz_user [Models::Rolable] the user from which the roles are going to be used
      # @return [ActiveRecord_Relation] the subset of records to which the user has access to
      def self.apply_scopes_for_user(collection_or_class, authz_user)
        usr = authz_user

        base = collection_or_class.all
        scoped = base.none
        usr.roles.each do |role|
          # TODO: an alternative implementation would be to use SQL UNION
          # This would allow us to circumvent ActiveRecord#or structural
          # limitations that forces us to always perform joins inside
          # Scopables::Base.apply_scopable_method_name.
          # See https://github.com/brianhempel/active_record_union
          # for a gem that implements AR union
          scoped = scoped.or(apply_role_scopes(role, base, usr))
        end
        scoped
      end

      # Applies all the applicable scopables to the given collection or class
      # using the scoping rules from the given role.
      #
      # @param role [Authz::Role] the role used to find the scoping rules to apply
      # @param collection_or_class [ActiveRecord_Relation, Class]
      #                            the starting collection on top
      #                            of which the scoping is going to
      #                            be applied
      # @param authz_user [Models::Rolable] the requesting user (injected dependency)
      # @return [ActiveRecord_Relation] the subset of records to which the role has access to
      def self.apply_role_scopes(role, collection_or_class, authz_user)
        applicable_scopables = Authz::Scopables::Base.get_applicable_scopables! collection_or_class

        scoped = collection_or_class.all

        applicable_scopables.each do |as|
          # as = ScopableByCity

          kw = role.cached_granted_keyword_for(as)
          # kw = 'New York'

          scoped = scoped.send(as.apply_scopable_method_name, kw, authz_user)
          # scoped.apply_scopable_by_city('New York', User#123)
        end

        scoped
      end

    end
  end
end

