require 'minitest/autorun'
require 'minitest/unit'
require 'pry'

module Base
  def ~@
    NEG.new(self)
  end

  def neg?(p)
    (is_a?(NEG) && self.p == p) ||
    (p.is_a?(NEG) && p.p == self)
  end

  def is_neg?
    is_a?(NEG)
  end

  def is_or?
    is_a?(FOR) && @ope == :+
  end

  def is_and?
    is_a?(FOR) && @ope == :*
  end

  def include?(p)
    false
  end

  def *(q)
    case q
    when Taut
      self
    when UTaut
      $utout
    when self
      self
    else
      if q.neg?(self)
        $utout
      else
        FOR.new(self, q, :*)
      end
    end
  end

  def +(q)
    case q
    when Taut
      $tout
    when UTaut
      self
    when self
      self
    else
      if q.neg?(self)
        $tout
      else
        FOR.new(self, q, :+)
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

class Taut
  include Base
  def ~@
    UTaut.new
  end

  def +(q)
    self
  end

  def *(q)
    q
  end
  def !@;            self;    end

  def to_s
    'TRUE'
  end
end

$tout = Taut.new

class UTaut
  include Base
  def ~@
    Taut.new
  end

  def +(q)
    q
  end

  def *(q)
    self
  end
  def !@;            self;    end
  def to_s
    'FALSE'
  end
end

$utout = UTaut.new

$atoms = []
def _(p)
  if atom = $atoms.find{|a|a.p == p}
    atom
  else
    atom = Atom.new(p)
    $atoms << atom
    atom
  end
end

class Atom
  include Base
  attr_accessor :p
  def initialize(p); @p = p;  end
  def to_s;          @p.to_s; end
  def !@;            self;    end
end

# if p.is_neg?
#     elsif p.is_or?
#     elsif p.is_or?
#     elsif p.is_and?


class NEG
  include Base
  attr_accessor :p
  def initialize(p); @p = p;       end
  def to_s;          "~#{@p}";     end
  def !@
    if p.is_neg?
      !p.p
    elsif p.is_or?
      ~(!p.p) * ~(!p.q)
    elsif p.is_and?
      ~(!p.p) + ~(!p.q)
    else
      ~(!p)
    end
  end
end


class FOR
  include Base
  attr_accessor :p, :q, :ope
  def initialize(p, q, ope); @p, @q, @ope = p, q, ope; end

  def include?(p)
    @p == p || @q == p
  end

  def to_s; "(#{@p}#{@ope == :* ? '&' : '|'}#{@q})"; end

  def !@
    (!@p).send(@ope, !@q)
  end
end



class TestArray < MiniTest::Unit::TestCase

  def setup
    $p = _(:P)
    $q = _(:Q)
  end
  def assert_to_s(exp, obj)
    assert_equal(exp, ((!obj).to_s))
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

  def test_normal_form
    assert_to_s("P", $p)
    assert_to_s("(P|Q)", $p + $q)
    assert_to_s("(P|Q)", $p + $q)
    # assert_to_s("(~P|Q)", _(:P) >= _(:Q))
    # assert_to_s("((~P|Q)&(~Q|P))", _(:P) <=> _(:Q))
    # assert_to_s("P", ~(~_(:P)))
    # assert_to_s("(~P&~Q)", ~(_(:P) + _(:Q)))

    # assert_to_s(
    #   "((P|Q)&(P|R))",
    #   (
    #     _(:P) +
    #     (_(:Q) * _(:R))
    #   )
    # )
  end
end