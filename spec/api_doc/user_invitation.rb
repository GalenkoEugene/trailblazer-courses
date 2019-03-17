# frozen_string_literal: true

module ApiDoc
  module UserInvitation
    extend ::Dox::DSL::Syntax

    document :api do
      resource 'User Invitation' do
        endpoint '/user_invitation'
        group 'User Invitatation'
      end
    end

    document :create do
      action 'Creates user invitation token'
    end
  end
end
