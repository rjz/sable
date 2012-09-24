module Sable

  # The base class to use for notifiables
  mattr_accessor :notifiable_class_name
  @@notifiable_class_name = 'Notification'

  # The foreign_key to use for notifiables
  mattr_accessor :notifiable_recipient_class_name
  @@notifiable_recipient_class_name = 'User'

  # The foreign_key to use for notifiables
  mattr_accessor :subscriber_class_name
  @@subscriber_class_name = 'User'

  # Compatibility: name of subscriber relation in subscription
  mattr_accessor :subscriber_relation_name
  @@subscriber_relation_name = 'subscriber'

  # Enable initializer
  def self.setup
    yield self
  end

  %w(acceptable notifiable notifiable_recipient subscriber subscribable).each do |m|
    require "concerns/#{m}"
  end

end
