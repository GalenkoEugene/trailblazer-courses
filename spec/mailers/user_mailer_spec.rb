# frozen_string_literal: true

RSpec.describe UserMailer, type: :mailer do
  let(:user) { create(:user) }

  shared_examples 'mail with correct headers' do
    it 'renders the headers' do
      expect(mail.subject).to eq(mail_subject)
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(['no-reply@example.com'])
    end
  end

  describe '.reset_password' do
    let(:url) { 'https://reset_password_url' }
    let(:mail) do
      described_class.reset_password(user, url, token)
    end

    let(:token) { Service::JWTAdapter.encode(aud: 'reset_password', sub: user.id, exp: 1.day.from_now.to_i) }
    let(:link) { "#{url}?token=#{token}" }

    it_behaves_like 'mail with correct headers' do
      let(:mail_subject) { I18n.t('user_mailer.reset_password.subject') }
    end

    it 'renders the body with restore password link' do
      expect(mail.body.encoded).to include(link)
    end
  end

  describe '.invite_user' do
    let(:url) { 'https://invite_user_url' }
    let(:mail) do
      described_class.invite_user(user, url, token)
    end

    let(:token) { Service::JWTAdapter.encode(aud: 'user_invitation', sub: user.id, exp: 1.day.from_now.to_i) }
    let(:link) { "#{url}?token=#{token}" }

    it_behaves_like 'mail with correct headers' do
      let(:mail_subject) { I18n.t('user_mailer.invite_user.subject') }
    end

    it 'renders the body with invitation link' do
      expect(mail.body.encoded).to include(link)
    end
  end
end
