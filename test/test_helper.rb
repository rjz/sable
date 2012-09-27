# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)

require "rails/test_help"

Rails.backtrace_cleaner.remove_silencers!

class TableBuilder

  def initialize
    @klass = Class.new(ActiveRecord::Base)
    @connection = @klass.connection
  end

  def create_table(table_name, params)
    @connection.create_table(table_name, :temporary => true) do |table|
      params.each do |key, value|
        table.send(value.to_sym, key.to_sym)
      end
    end
  end
end

tb = TableBuilder.new

tb.create_table 'acceptable_klasses', {
  :id => :integer,
  :state => :integer
}

tb.create_table 'notifiable_klasses', {
  :id => :integer
}

tb.create_table 'notifications', {
  :id             => :integer,
  :type           => :string,
  :model_id       => :integer,
  :model_type     => :string,
  :recipient_id   => :integer,
  :recipient_type => :string
}

tb.create_table 'users', {
  :id => :integer
}

tb.create_table 'subscribable_klasses', {
  :id => :integer
}

tb.create_table 'subscriptions', {
  :id                => :integer,
  :subscribable_id   => :integer,
  :subscribable_type => :string,
  :subscriber_id     => :integer,
  :level             => :integer
}

# A default notification recipient
class User < ActiveRecord::Base
  include Sable::NotifiableRecipient
  include Sable::Subscriber
end

# A default notification class
class Notification < ActiveRecord::Base
  belongs_to :model, :polymorphic => true
end

# A subscribable class
class SubscribableKlass < ActiveRecord::Base
  include Sable::Subscribable
end


class Subscription < ActiveRecord::Base
  
  belongs_to :subscriber,
    :class_name => 'User'

  belongs_to :subscribable,
    :polymorphic => true

  after_create  :callback_subscribe
  after_destroy :callback_unsubscribe

  def method_missing(meth, *args, &block)
    if meth.to_s =~ /^callback_(.+)$/
      subscribable.run_callbacks($1.to_sym)
    else
      super
    end
  end

  Levels = {
    :deity    => 6,
    :emperor  => 5,
    :king     => 4,
    :prince   => 3,
    :warlord  => 2,
    :chieftan => 1
  }
  
  def >(level)
    return self.level > level
  end

end

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

