module Sable::Subscribable

  extend ActiveSupport::Concern

  module ClassExtensions

    def after_subscribe(callback)
      self.set_callback :subscribe, :after, callback
    end

    def after_unsubscribe(callback)
      self.set_callback :unsubscribe, :after, callback
    end
  end

  included do

    include ActiveRecord::Callbacks
    extend ClassExtensions

    has_many :subscriptions_to,
      :class_name => 'Subscription',
      :as => 'subscribable',
      :dependent => :destroy,
      :uniq => true

    has_many :subscribers,
      :source => Sable.subscriber_relation_name,
      :class_name => Sable.subscriber_class_name,
      :through => :subscriptions_to

    define_callbacks :subscribe, :unsubscribe

    alias_method :subscriber?, :subscription_to?
  end

  # subscribe a user to this resource
  def subscribe(subscriber, subscription_level = Subscription::Levels[:reader])

    if sub = subscription_to(subscriber)
      # no need for equine abuse post-mortem
      return if sub.level == subscription_level
    else
      # Build a subscription
      sub = self.subscriptions_to.build(Sable.subscriber_relation_name.to_sym => subscriber)

      # Manually assigning +subscribable+ ensures the current instance will
      # carry forward (useful in combination with +suppress_notifiables+)
      sub.subscribable = self
    end

    sub.level = subscription_level
    sub.save! unless new_record?
  end

  # Find a subscription for the subscriber, optionally limited to the 
  # subscription level specified
  def subscription_to(subscriber, subscription_level = nil)
    matches = self.subscriptions_to.where(:"#{Sable.subscriber_relation_name.to_sym}_id" => subscriber.id)
    matches = matches.where('level >= ?', subscription_level) unless subscription_level == nil
    (matches.length > 0) ? matches.first : nil
  end

  # Convenience: Boolean version of +subscribed+
  def subscription_to?(subscriber, subscription_level = nil)
    !subscription_to(subscriber, subscription_level).nil?
  end

  def unsubscribe(subscriber)
    # Retrieve all of +subscriber+'s subscriptions. There really 
    # shouldn't be more than one...but we'll cover bases...
    subscriptions = self.subscriptions_to.where(:"#{Sable.subscriber_relation_name.to_sym}_id" => subscriber.id)
    subscriptions.all.each do |sub|
      sub.destroy
    end
  end

  # Perform an action on each subscriber subscribed to this resource
  # +opts+ include:
  #   - +:except+: omit a subscriber or array of subscribers
  def each_subscriber(opts = {})
    o = { :except => [] }.merge(opts)

    o[:except] = [o[:except]] unless o[:except].kind_of?(Array)

    subscribers.each do |subscriber|
      yield subscriber unless o[:except].include?(subscriber)
    end
  end
end

