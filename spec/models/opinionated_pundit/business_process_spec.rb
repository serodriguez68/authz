require 'rails_helper'

module OpinionatedPundit
  RSpec.describe BusinessProcess, type: :model do
    describe 'validations' do
      it { is_expected.to validate_presence_of :code }
      it { is_expected.to validate_presence_of :name }
      it { is_expected.to validate_presence_of :description }
      it { is_expected.to validate_uniqueness_of(:code) }
      it { is_expected.to validate_uniqueness_of(:name) }
      it { should allow_value('valid').for(:code) }
      it { should allow_value('valid_code').for(:code) }
      it { should_not allow_value('Invalid').for(:code) }
      it { should_not allow_value('9_a').for(:code) }

      it 'should automatically extract the code from the name' do
        bp = create(:opinionated_pundit_business_process, code: nil,
                                                          name: 'Manage Reports')
        expect(bp.code).to eq 'manage_reports'
      end
    end


  end
end
