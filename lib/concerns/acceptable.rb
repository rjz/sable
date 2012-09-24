# A mixin for smoothing over notifications
require 'active_record'

module Sable::Acceptable

  Accepted = 1
  Pending = 0
  Rejected = -1

  extend ActiveSupport::Concern

  module ClassExtensions

    # Helper for registering +after_accept+ callbacks
    def after_accept(callback)
      self.set_callback :accept, :after, callback
    end

    # Helper for registering +after_reject+ callbacks
    def after_reject(callback)
      self.set_callback :reject, :after, callback
    end
  end

  included do 

    include ActiveRecord::Callbacks
    extend ClassExtensions

    define_callbacks :accept, :reject

    instance_eval do
      @acceptable_state ||= Sable::Acceptable::Pending
    end
  end

  # Accept the current model
  def accept
    run_callbacks :accept do
      @acceptable_state = Sable::Acceptable::Accepted
    end
  end

  # Has the current model been accepted?
  def accepted?
    @acceptable_state == Sable::Acceptable::Accepted
  end

  # Reject the current model
  def reject
    run_callbacks :reject do
      @acceptable_state = Sable::Acceptable::Rejected
    end
  end

  # Has the current model been rejected?
  def rejected?
    @acceptable_state == Sable::Acceptable::Rejected
  end

end

