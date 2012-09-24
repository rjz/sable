# Helper for subscribers to subscribable resources
module Sable::Subscriber
  extend ActiveSupport::Concern

  included do
    has_many :subscriptions, 
      :dependent => :destroy, 
      :foreign_key => Sable.subscriber_relation_name + '_id'

    has_many :subscribables,
      :through => :subscriptions,
      :as => :subscribable
  end
  
  # check if subscribed to a subscribable model
  #
  # +subscribable+  a model including Sable::Subscribable
  # +subscription_level+  the (minimum) level of the subscription
  #
  # returns first subscription (if found) or +nil+ if no subscription
  # matched the request
  def subscribed(subscribable, subscription_level = nil)
    subscribable.subscription_to(self, subscription_level)
  end

  # Boolean version of +subscribed+
  def subscribed?(subscribable, subscription_level = nil)
    subscribed(subscribable, subscription_level) != nil
  end

  # create or modify a subscription
  #
  # +subscribable+  a model including Sable::Subscribable
  # +subscription_level+  the (minimum) level of the subscription
  #
  # returns false if no changes were made
  def subscribe(subscribable, subscription_level = Subscription::Levels[:reader])
    subscribable.subscribe(self, subscription_level)
  end

  # destroy a subscription
  #
  # +subscribable+  a model including Sable::Subscribable
  #
  # returns false if no changes were made
  def unsubscribe(subscribable)
    subscribable.unsubscribe(self)
  end
  
end
