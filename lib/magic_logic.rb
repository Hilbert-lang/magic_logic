require "magic_logic/version"

module MagicLogic
  module Operator
    def _ ope, l, r
      ope == :+ ? l : r
    end

    [:+, :*].each do |ope|
      define_method(ope) do |q|
        case q
        when Taut  then _ ope, $tout, self
        when UTaut then _ ope, self, $utout
        when self  then self
        else
          if neg?(q)
            (_ ope, $tout, $utout)
          elsif is_form?(ope.to_sym) && include?(q)
            self
          elsif q.is_form?(ope) && q.include?(self)
            q
          else
            FORM.new([self, q], ope)
          end
        end
      end
    end

    def ~@
      if    is_neg?  then p
      elsif is_form? then vars.map(&:~).inject(_ ope, :*, :+)
      else                NEG.new(self)
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
    ATOM_PREFIX = "__ATOM__PREFIX__"

    def neg?(p)
      (is_neg? && self.p == p) || (p.is_neg? && p.p == self)
    end

    def is_neg?
      is_a?(NEG)
    end

    def is_form?(ope=nil)
      return is_a?(FORM) && self.ope == ope if ope
      is_a?(FORM)
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

    def evl
      case self
      when Taut  then "(true)"
      when UTaut then "(false)"
      when Atom  then "(#{ATOM_PREFIX}#{$atoms.index(self)})"
      when FORM  then "(#{vars.map(&:evl).join(_ ope, '||', '&&')})"
      when NEG   then "(!#{p.evl})"
      end
    end

    class ::String
      def sbst!(num, bool)
        gsub!(/#{ATOM_PREFIX}#{num}/, bool.to_s)
      end
    end

    def dpll
      case self
      when *[Taut, UTaut, Atom]
        self
      else
        #TODO: refactor
        count = $atoms.count
        rslt = (1 .. 2 ** count).map do |i|
          s = evl
          count.times { |j| s.sbst!(j, (i >> j) & 1 == 1)  }
          eval(s)
        end
        case rslt.uniq
        when [true]  then $tout
        when [false] then $utout
        else              self
        end
      end
    end
  end

  module Base; include Operator; include Utils end

  # Tautology
  class Taut
    include Base
    def ~@;   $utout end
    def +(q); $tout  end
    def *(q); q      end
    def to_s; 'TRUE' end
  end
  $tout = Taut.new

  # Non Tautology
  class UTaut
    include Base
    def ~@;   $tout   end
    def +(q); q       end
    def *(q); $utout  end
    def to_s; 'FALSE' end
  end
  $utout = UTaut.new

  class Atom < Struct.new(:p)
    include Base
    def to_s;  p.to_s end

    class << self
      def [](x)
        new(x).tap { |p| $atoms << p; $atoms.uniq! }
      end
    end
  end
  P = Atom
  $atoms = []

  class NEG < Struct.new(:p)
    include Base
    def to_s;  "~#{p}"    end
  end

  class FORM < Struct.new(:vars, :ope)
    include Base
    def initialize(vars, ope)
      self.vars = vars.map { |var| var.is_form?(ope) ? var.vars : var }.flatten
      self.ope = ope
    end

    def to_s;        "(#{vars.map(&:to_s).join(_ ope, '|', '&')})" end
    def include?(p); vars.include?(p)                              end
  end

  class ::Array
    def >>(con)
      l = inject($tout) { |s, p| s * p } >= con
      case l.dpll
      when Taut  then 'TRUE'
      when UTaut then 'FALSE'
      else            'UNDECIDABLE'
      end
    end
  end
end
include MagicLogic
