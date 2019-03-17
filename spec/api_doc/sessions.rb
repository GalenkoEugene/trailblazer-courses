# frozen_string_literal: true

module ApiDoc
  module Sessions
    extend ::Dox::DSL::Syntax

    document :api do
      resource 'Sessions' do
        endpoint '/account/session'
        group 'Sessions'
      end
    end

    document :create do
      action 'Create user session'
    end

    document :destroy do
      action 'Destroy user session'
    end
  end
end
