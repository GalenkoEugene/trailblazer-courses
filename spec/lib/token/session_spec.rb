# frozen_string_literal: true

RSpec.describe Auth::Token::Session do
  let(:user) { create(:user) }
  let(:token) { described_class.generate(user) }

  describe '.generate' do
    it 'generates session token' do
      expect(token).to be
    end
  end

  describe '.find_user_by_token' do
    context 'valid token' do
      it 'find user by token' do
        expect(described_class.find_user_by_token(token)).to eq user
      end
    end

    context 'invalid token' do
      it 'find user by token' do
        expect(described_class.find_user_by_token('invalid.token')).to be_nil
      end
    end
  end
end
