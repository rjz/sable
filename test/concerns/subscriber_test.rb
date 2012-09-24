require 'test_helper'

class Sable::SubscriberTest < ActiveSupport::TestCase

  setup do
    @subscriber = User.new
    @subscribable = SubscribableKlass.new

    @subscriber.save
    @subscribable.save
  end

  test 'subscribe' do
    assert_difference 'Subscription.count' do
      @subscriber.subscribe(@subscribable)
    end

    assert @subscribable.subscriber?(@subscriber)
    assert @subscriber.subscribed?(@subscribable)
  end

end
