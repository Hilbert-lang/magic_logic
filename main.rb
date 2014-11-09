#!/bin/env ruby
# encoding: utf-8

# P(1)
# ∀x ¬P(x) or Q(x)
# Q(1)
# => true
# は

Atm.new(:P, 1).def!
A.new(OR.new(
       Ng.new(Atm.new(:P, nil)),
       Ng.new(Atm.new(:Q, nil))
     )
).def!

Atm.new(:Q, 1).eval!


Atm.def!(:P, :x)
Atm.def!(:Q, :y)
OR.new(
  Ng.new(Atm.new(:P, :x)),
  Ng.new(Atm.new(:Q, :y))
).eval!


module World
  class Entity
  end
end

$world = World::Entity

module World
  class Entity
    @@truth = %i(atoms negatives disjunctions conjunctions universals).reduce({}) do |hash, k|
      hash[k] = []
      hash
    end
    class << self
      def <<(logic)
        case logic
        when Atom        then @@truth[:atoms]         << logic
        when Negative    then @@truth[:negatives]     << logic
        when Disjunction then @@truth[:disjunctions]  << logic
        when Conjunction then @@truth[:conjunctions]  << logic
        when Universal   then @@truth[:universals]    << logic
        end
      end

      # Accesor
      def truth
        @@truth
      end

      def atoms
        @@truth[:atoms]
      end

      def reset
        @@truth = %i(atoms negatives disjunctions conjunctions universals).reduce({}) do |hash, k|
          hash[k] = []
          hash
        end
      end
    end
  end
end

class Logic
end

# P(1)　原子論理式
# Atom.def!(:P, 1)
class Atom < Logic
  attr_accessor :pred, :term

  def initialize(pred, term)
    @pred, @term = pred, term
  end

  def def!
    $world << self
  end

  def eval!
    !!$world.atoms.find { |atom| atom.pred == @pred && atom.term ==  @term }
  end
end
Atm = Atom

# ∀ 全称論理
# ∀x P(x) は
# Universal.def!(Atom.new(:P, 1))
class Universal < Logic
  attr_accessor :logic

  def initialize(logic)
    @logic = logic
  end

  def def!
    $world << self
  end

  def eval!
  end
end
A = Universal


# 否定
class Negative < Logic
  attr_accessor :logic

  def initialize(logic)
    @logic = logic
  end

  def def!
    $world << self
  end

  def eval!
    !logic.eval!
  end
end
Ng = Negative

# 論理和
class Disjunction < Logic
  attr_accessor :logic1, :logic2

  def initialize(logic1, logic2)
    @logic1, @logic2 = logic1, logic2
  end

  def def!
    $world << self
  end

  def eval!
    logic1.eval! || logic2.eval!
  end
end
OR = Disjunction

# 論理積
class Conjunction < Logic
  attr_accessor :logic1, :logic2

  def initialize(logic1, logic2)
    @logic1, @logic2 = logic1, logic2
  end

  def def!
    $world << self
  end

  def eval!
    logic1.eval! && logic2.eval!
  end
end
AND = Conjunction
