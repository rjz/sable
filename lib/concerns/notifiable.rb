# A mixin for smoothing over notifications
module Sable::Notifiable

  extend ActiveSupport::Concern

  module ClassExtensions

    attr_reader :notifiables

    # Create a notifiable method
    def create_notifiable(chain_name, opts = {})
      @notifiables ||= {}

      # Determine whether a recipient is already associated with this class
      default_recipient = Sable.notifiable_recipient_class_name.underscore.to_sym
      default_recipient = self.method_defined?(default_recipient) ? default_recipient : nil

      defaults = {
        # By default, assign notifications to a recipient owner of this class
        :recipients => default_recipient,

        # Default notification will use the type defined in Sableconfig
        :type => Sable.notifiable_class_name
      }

      notifiable = defaults.update(opts)
      
      # Create a notifiable chain if it does not yet exist
      unless @notifiables.key?(chain_name)
        @notifiables[chain_name] = []
        self.send(:define_method, :"run_notifiable_#{chain_name}") { process_notifiables(chain_name) }
      end

      # Don't add a notifiable twice!
      return if @notifiables[chain_name].include?(notifiable)

      # Add the notifiable to the chain
      @notifiables[chain_name] << notifiable
    end

  end

  included do
  
    self.class_eval do
      extend ClassExtensions
    end

    before_destroy :destroy_notifiables
  end

  # Callback: +before_destroy+, remove all related recommendations
  def destroy_notifiables
    self.class.notifiables.values.flatten.each do |notifiable|
      model = resolve_notifiable_field(notifiable, :model) || self

      params = {
        :model_type => model.class.model_name,
        :model_id => self.id
      }

      notifiable[:type].where(params).delete_all
    end
  end

  # Suppress notification dispatching for the current instance
  def suppress_notifiables
    @notifiables_suppressed = true
  end

  protected

    # Evaluate notifiable fields in various formats
    def resolve_notifiable_field(notifiable, field)
      result = nil
      if notifiable.key?(field)
        case param = notifiable[field]
          when Proc # Evaluate proc
            result = param.call(self)
          when Symbol # Attempt to evaluate named instance method 
            result = self.send(param)
          when String # Attempt to lookup constant referenced by string
            result = param.constantize
          else # Fall through
            result = param
        end
      end
      result
    end

    # Process all notifiables associated with a specific +callback+
    # +name+ is the name of the notifiable item to be created
    def process_notifiables(name)
      
      return if @notifiables_suppressed == true

      # Fire each notifiable in the named chain
      self.class.notifiables[name].each do |notifiable|

        # Resolve the model
        model = resolve_notifiable_field(notifiable, :model) || self

        # Resolve the recipients and convert to an array
        recipients = resolve_notifiable_field(notifiable, :recipients)
        recipients = [recipients] unless recipients.respond_to?(:each)

        # Resolve the model type
        notification_klass = resolve_notifiable_field(notifiable, :type) || notifiable[:type]

        # Notify each recipient
        recipients.each do |recipient|
          notification = notification_klass.new
          notification.model = model
          recipient.notifications << notification
        end
      end
    end
end
