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

    # Set default state
    after_initialize Proc.new { |m| m.state ||= Sable::Acceptable::Pending }
  end

  def acceptable?
    self.state == Sable::Acceptable::Pending
  end

  # Accept the current model
  def accept
    return unless acceptable?
    run_callbacks :accept do
      self.state = Sable::Acceptable::Accepted
    end
  end

  # Has the current model been accepted?
  def accepted?
    self.state == Sable::Acceptable::Accepted
  end

  # Reject the current model
  def reject
    return unless acceptable?
    run_callbacks :reject do
      self.state = Sable::Acceptable::Rejected
    end
  end

  # Has the current model been rejected?
  def rejected?
    self.state == Sable::Acceptable::Rejected
  end


end

