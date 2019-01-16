require_dependency "authz/application_controller"

module Authz
  class ScopingRulesController < ApplicationController
    def new
      @role = Role.find(params[:role_id])
      @scopable = params[:scopable]
      @scoping_rule = ScopingRule.new(scopable: @scopable)
      @available_keywords = @scopable.constantize.available_keywords
    end

    def create
      @role = Role.find(params[:role_id])
      @scopable = scoping_rule_params[:scopable]
      @scoping_rule = ScopingRule.new(scoping_rule_params.merge(authz_role_id: @role.id))
      @available_keywords = @scopable.constantize.available_keywords
      if @scoping_rule.save
        redirect_to role_path(@role)
      else
        render 'new'
      end
    end

    def edit
      @role = Role.find(params[:role_id])
      @scoping_rule = ScopingRule.find(params[:id])
      @available_keywords = @scoping_rule.scopable.constantize.available_keywords
    end

    def update
      @role = Role.find(params[:role_id])
      @scoping_rule = ScopingRule.find(params[:id])
      if @scoping_rule.update(scoping_rule_update_params)
        redirect_to role_path(@role)
      else
        @available_keywords = @scoping_rule.scopable.constantize.available_keywords
        render 'edit'
      end

    end

    private

    def scoping_rule_params
      params.require(:scoping_rule)
            .permit(
              :scopable,
              :keyword
            )
    end

    def scoping_rule_update_params
      params.require(:scoping_rule)
            .permit(:keyword)
    end
  end
end
