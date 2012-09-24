module Sable::NotifiableRecipient

  extend ActiveSupport::Concern

  included do
    #FIXME: foreign_key is disgusting
    has_many :notifications,
      :class_name => Sable.notifiable_class_name,
      :foreign_key => Sable.notifiable_recipient_class_name.constantize.table_name.singularize.foreign_key,
      :dependent => :destroy
  end
end

