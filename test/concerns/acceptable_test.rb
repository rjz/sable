require 'test_helper'

class AcceptableKlass < ActiveRecord::Base
  include Sable::Acceptable

  after_accept :do_after_accept
  after_reject :do_after_reject

  ['accept','reject'].each do |m|
    self.instance_variable_set :"@#{m}_called", false
    define_method(:"#{m}_called?") { self.instance_variable_get(:"@#{m}_called") }
    define_method(:"do_after_#{m}") { self.instance_variable_set(:"@#{m}_called", true) }
  end

end

class Sable::AcceptableTest < ActiveSupport::TestCase

  setup do
    @acceptable = AcceptableKlass.new
  end

  test 'defaults' do
    assert_equal Sable::Acceptable::Pending, @acceptable.state
  end

  test 'acceptable actions' do
    actions = ['accept','reject']
    actions.each do |action|
      assert @acceptable.acceptable_actions.include?(action)
    end
  end

  test 'accept' do
    @acceptable.accept
    assert @acceptable.accept_called?
    assert @acceptable.accepted?
  end
 
  test 'reject' do
    @acceptable.reject
    assert @acceptable.reject_called?
    assert @acceptable.rejected?
  end

  test 'fail accept+reject unless pending' do
    @acceptable.accept
    @acceptable.reject
    assert @acceptable.accepted?

    @acceptable = AcceptableKlass.new
    @acceptable.reject
    @acceptable.accept
    assert @acceptable.rejected?
  end
end

