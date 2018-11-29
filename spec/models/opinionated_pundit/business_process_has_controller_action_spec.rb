require 'rails_helper'

module OpinionatedPundit
  RSpec.describe BusinessProcessHasControllerAction, type: :model do
    # skip: 'Shoulda has problems with nested models
    describe 'Associations' do
      it { should belong_to(:controller_action) }
      it { should belong_to(:business_process) }
    end

    describe 'validations' do

      it { should validate_presence_of(:controller_action).with_message(:required) }
      it { should validate_presence_of(:business_process).with_message(:required) }
      it do
        bphca = create(:opinionated_pundit_business_process_has_controller_action)
        expect(bphca).to validate_uniqueness_of(:opinionated_pundit_controller_action_id).scoped_to(:opinionated_pundit_business_process_id)
      end

    end

  end
end
