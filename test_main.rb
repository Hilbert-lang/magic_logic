require 'minitest/autorun'
require 'minitest/unit'
require 'pry'

module Operator
  def ~@
    if    is_neg?  then p
    elsif is_form? then vars.map { |a|~a }.inject(reope)
    else                NEG.new(self)
    end
  end

  def *(q)
    case q
    when Taut  then self
    when UTaut then $utout
    when self  then self
    else
      if neg?(q) then $utout
      else            and_([self, q])
      end
    end
  end

  def +(q)
    case q
    when Taut  then $tout
    when UTaut then self
    when self  then self
    else
      if neg?(q) then $tout
      else            or_([self, q])
      end
    end
  end

  def >=(q)
    (~self + q)
  end

  def <=>(q)
    (self >= q) * (q >= self)
  end
end

module Utils
  def neg?(p)
    (is_a?(NEG) && self.p == p) ||
    (p.is_a?(NEG) && p.p == self)
  end

  def is_neg?
    is_a?(NEG)
  end

  def is_form?(ope=true)
    return is_a?(FORM) if ope === true
    is_a?(FORM) && @ope == ope
  end

  def is_or?
    is_form?(:+)
  end

  def is_and?
    is_form?(:*)
  end

  def include?(p)
    false
  end
end

module Base; include Operator; include Utils end

# Tautology
class Taut
  include Base
  def ~@;   $utout end
  def +(q); $tout  end
  def *(q); q      end
  def !@;   $tout  end
  def to_s; 'TRUE' end
end
$tout = Taut.new

# Non Tautology
class UTaut
  include Base
  def ~@;   $tout   end
  def +(q); q       end
  def *(q); $utout  end
  def !@;   $utout  end
  def to_s; 'FALSE' end
end
$utout = UTaut.new

class Atom
  include Base
  attr_accessor :p
  def initialize(p); @p = p  end
  def to_s;          @p.to_s end
  def !@;            self    end
  def deep;          1       end
end
$atoms = []
def _(p)
  if atom = $atoms.find { |a| a.p == p }
    atom
  else
    Atom.new(p).tap { |a| $atoms << a }
  end
end

class NEG
  include Base
  attr_accessor :p
  def initialize(p); @p = p     end
  def to_s;          "~#{@p}"   end
  def !@;             ~(!p)     end
  def deep;          p.deep+1   end
end


class FORM
  include Base
  attr_accessor :vars, :ope
  def initialize(vars, ope)
    vars = vars.map { |var| var.is_form?(ope) ? var.vars : var }.flatten
    @vars, @ope = vars, ope
  end

  def include?(p)
    vars.include?(p)
  end

  def to_s
    str = vars.each.with_index.inject('(') do |str, (p, i)|
      str = str + "#{p}#{i < vars.count-1 ? loope : ')'}"
      str
    end
  end

  def loope
    @ope == :* ? '&' : '|'
  end

  def reope
    is_and? ? :+ : :*
  end

  def are_there_neg?
    pvars = vars.reject { |var| var.is_neg? }
    nvars = vars.select { |var| var.is_neg? }
    pvars.any? { |pvar|
      nvars.any? { |nvar| nvar.neg?(pvar) }
    }
  end

  def !@
    if is_or?
      if and_form = vars.find { |var| var.is_and? }
        and_form.vars.map { |a| a + or_(vars - [and_form]) }.inject(:*)
      elsif are_there_neg?
        $tout
      else
        vars.map{|a|!a}.inject(@ope)
      end
    elsif is_and? && are_there_neg?
      $utout
    else
      vars.map{|a|!a}.inject(@ope)
    end
  end
  def deep;          [p.deep, q.deep].max+1;     end
end
def or_(vars);  FORM.new(vars, :+) end
def and_(vars); FORM.new(vars, :*) end


class TestArray < MiniTest::Unit::TestCase
  def setup
    $p = _(:P)
    $q = _(:Q)
    $r = _(:R)
  end
  def assert_to_s(exp, obj)
    assert_equal(exp, ((!!!!!!!obj).to_s))
  end

  def test_utils
    assert_equal(true, $p.neg?(~$p))
    assert_equal(true, (~$p).neg?($p))
    assert_equal(false, ($p).neg?($p))
    assert_equal(false, ($p).neg?($p))
    assert_equal(true, ($p + $q).include?($p))
    assert_equal(true, ($p + $q).include?($q))
  end

  def test_0_1
    assert_to_s("TRUE", $p + $tout)
    assert_to_s("TRUE", $tout + $p)
    assert_to_s("P", $p + $utout)
    assert_to_s("P", $utout + $p)
    assert_to_s("TRUE", $p + ~$p)
    assert_to_s("TRUE", ~$p + $p)

    assert_to_s("P", $p * $tout)
    assert_to_s("P", $tout * $p)
    assert_to_s("FALSE", $p * $utout)
    assert_to_s("FALSE", $utout * $p)
    assert_to_s("FALSE", $p * ~$p)
    assert_to_s("FALSE", ~$p * $p)
  end

  def test_basis
    assert_to_s("P", $p)
    assert_to_s("(P|Q)", $p + $q)
    assert_to_s("(P&Q)", $p * $q)
    assert_to_s("~P", ~$p)
    assert_to_s("(~P|Q)", $p >= $q)
    assert_to_s("((~P|Q)&(~Q|P))", $p <=> $q)
  end

  def test_main
    assert_to_s("(~P&~Q)", ~($p + $q))
    assert_to_s("(~P|~Q)", ~($p * $q))
    assert_to_s("P", ~(~$p))
    assert_to_s("((Q|P)&(R|P))", $p + ($q * $r))
    assert_to_s("(P&Q&R)", $p * ($q * $r))
    assert_to_s("(P&(~P|Q))", $p * ($p >= $q))
  end

  def test_tautology
    assert_to_s("TRUE", ($p * ($p >= $q)) >= $q)
    assert_to_s("TRUE", (($p >= $q) * ($q >= $r)) >= ($p >= $r))
    assert_to_s("TRUE", (~$p * ($p + $q)) >= ($q))
    assert_to_s("TRUE", (($p >= $q) * ($q >= $r) * $p) >= ($r))
  end

  def test_no_tautology
    assert_to_s("FALSE", $p * $q * ~$p)
  end
end
