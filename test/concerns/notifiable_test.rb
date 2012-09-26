require 'test_helper'

# An extra notification class
class NotificationToo < Notification
  set_table_name 'notifications'
end

# A notifiable class
class NotifiableKlass < ActiveRecord::Base

  include Sable::Notifiable

  has_one :user

  after_initialize do 
    self.user = User.new
  end
end

class NotifiableChildKlass < NotifiableKlass 
  set_table_name 'notifiable_klass'
end

class Sable::NotifiableTest < ActiveSupport::TestCase

  setup do
    @notifiable = NotifiableKlass.new
    @notifiable.save
    
    @recipient = @notifiable.user
    @recipient.save

    NotifiableKlass.class_eval do
      create_notifiable :simple
    end

  end

  teardown do
    NotifiableKlass.class_eval do 
      self.notifiables = {}
      instance_methods.each do |meth|
        remove_method(meth) if meth =~ /^run_notifiable_/
      end
    end
  end

  test 'defaults' do
    NotifiableKlass.class_eval do
      create_notifiable :foobar
    end
    
    assert_difference "@recipient.notifications.all.length" do
      @notifiable.send :run_notifiable_foobar
    end
  end

  test 'descendants inherit notifiables' do
    NotifiableKlass.class_eval do
      create_notifiable :foobar
    end

    notifiables = NotifiableChildKlass.notifiables

    assert notifiables.is_a?(Hash)
    assert notifiables.key?(:foobar)
  end

  test 'create' do
    assert_difference "@recipient.notifications.all.length" do
      @notifiable.send :run_notifiable_simple
    end
  end

  test 'destroy' do
    assert_no_difference 'Notification.count' do
      assert_difference "@recipient.notifications.all.length" do
        @notifiable.send :run_notifiable_simple
      end
      @recipient.destroy
    end
  end

  test 'chain' do
    NotifiableKlass.class_eval do
      create_notifiable :multi,
        :type => NotificationToo
      create_notifiable :multi
    end

    assert_difference "@recipient.notifications.all.length", +2 do
      @notifiable.send :run_notifiable_multi
    end
  end

  test 'chain ignores repeats' do
    NotifiableKlass.class_eval do
      create_notifiable :multi
      create_notifiable :multi
    end

    assert_difference "@recipient.notifications.all.length", +1 do
      @notifiable.send :run_notifiable_multi
    end
  end

end

