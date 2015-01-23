$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'magic_logic'
require 'pry'
require 'minitest/autorun'

def assert_to_s(exp, obj)
  assert_equal(exp, obj.dpll.to_s)
end
