class Sable::SubscribableTest < ActiveSupport::TestCase

  setup do
    @subscribable = SubscribableKlass.new
    @subscribable.save
    
    @user = User.new
    @user.save
  end

  test 'create subscription' do
    assert_difference 'Subscription.count' do
      @subscribable.subscribe(@user)
    end

    assert @subscribable.subscriber?(@user)
    assert @user.subscribed?(@subscribable)
  end

  test 'only subscribe once' do
    assert_difference 'Subscription.count' do
      @subscribable.subscribe(@user)
    end

    assert_no_difference 'Subscription.count' do
      @subscribable.subscribe(@user)
    end

    assert @subscribable.subscriber?(@user)
    assert @user.subscribed?(@subscribable)

  end

  test 'destroys subscription with subscriber' do
    assert_no_difference 'Subscription.count' do
      @subscribable.subscribe(@user)
      @subscribable.destroy
    end
  end

  test 'destroys subscription with subscribable' do
    assert_no_difference 'Subscription.count' do
      @subscribable.subscribe(@user)
      @user.destroy
    end
  end

end

