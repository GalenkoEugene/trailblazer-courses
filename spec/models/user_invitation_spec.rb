# frozen_string_literal: true

RSpec.describe UserInvitation, type: :model do
  subject(:user) { described_class.new }

  context 'fields' do
    it { is_expected.to have_db_column(:email).of_type(:string) }
  end
end
