module Authz
  module Controllers
    module ScopingManager
      extend ActiveSupport::Concern

      # Errors =================================================================

      # Determines if the given role has access to the given instance
      # considering all the applicable scopables and the role's
      # scoping rules.
      #
      # @param role: role for which access is going to be determined
      # @param instance_to_check: any model instance trying to be manipulated
      # @param authz_user: user that is trying to access the instance
      #                    (injected dependency)
      def self.has_access_to_instance?(role, instance_to_check, authz_user)
        scoped_class = instance_to_check.class
        applicable_scopables = Authz::Scopables::Base.get_applicable_scopables! scoped_class
        scoping_rules = role.scoping_rules.for_scopables(applicable_scopables).load

        applicable_scopables.each do |as|
          kw = scoping_rules.find_by!(scopable: as.to_s).keyword
          return false unless as.within_scope_of_keyword?(instance_to_check,
                                                          kw,
                                                          authz_user)
        end

        return true
      end

      # Applies the applicable user scoping rules to a given collection or class
      # Fails safely if a user does not have all scoping rules needed
      #
      # @param user [User] user used to retrieve the scoping rules
      # @param collection_or_class [Collection, Class] collection or class on
      #        top of which the scoping rules will be applied
      # @raise [UserScopingRuleMissing] if user is missing the definition of
      #        scoping rule that applies
      # @return [Collection] resulting collection after applying
      #         all scoping rules
      def self.apply_user_scopes_for_user(user, collection_or_class)
        # 1. Find all scopables that are applicable to collection_or_class
        applicable_scoping_modules = Authz::Scopables::Base.get_applicable_scopables! collection_or_class
        stringified_applicable_scoping_modules = applicable_scoping_modules.map(&:to_s)

        # TODO: YOU ARE HERE: you where about to start plugging in how a user has some defined
        # scoping rules.
        # 2. Get user scoping rules based on scoping modules of 1.
        # load is used to skip lazy loading as it creates one additional quiery (counting query + user_scoping_rules query)
        # user_scoping_rules = user.user_scoping_rules.scoping_module_name_is(stringified_applicable_scoping_modules).includes(:profile_scoping_rule).load

        # Uncomment this to test what happens when a user does not have all
        # required user scoping rules
        # applicable_scoping_modules.push('SomeOtherScopingModule')
        # stringified_applicable_scoping_modules.push('SomeOtherScopingModule')

        # 3. Check that current user has definition for all scopables in (1)
        if user_scoping_rules.size != applicable_scoping_modules.size
          # 3.1 The user does not have all required user_scoping_rules
          missing_user_scoping_rules = stringified_applicable_scoping_modules - user_scoping_rules.pluck(:scoping_module_name)
          raise UserScopingRuleMissing, "#{missing_user_scoping_rules.join(', ')} not defined for user"

        else
          # 3.2 Apply user_scoping_rules to collection
          collection_to_return = collection_or_class.all
          table_name = collection_to_return.table_name

          user_scoping_rules.each do |usr|
            table_applicable_scoping_value = usr.applicable_scoping_value_for table_name: table_name
            collection_to_return = collection_to_return.send(usr.scoping_method_name, table_applicable_scoping_value, user)
          end
          return collection_to_return
        end
      end

    end
  end
end

