require 'test_helper'

class Sable::NotifiableRecipientTest < ActiveSupport::TestCase

  setup do
    @recipient = User.new
  end

  test 'has notifications' do
    assert @recipient.respond_to?(:notifications)
  end
end

