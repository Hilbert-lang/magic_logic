require "magic_logic/version"

module MagicLogic
  module Operator
    def _ ope, l, r
      ope.to_s == '+' ? l : r
    end

    %w|+ *|.each do |ope|
      define_method(ope) do |q|
        case q
        when Taut  then _ ope, $tout, self
        when UTaut then _ ope, self, $utout
        when self  then self
        else            neg?(q) ? (_ ope, $tout, $utout) : FORM.new([self, q], ope.to_sym)
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

    def dpll
      !!!!!!!!!!!!!!!!!!self
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

  class Atom < Struct.new(:p)
    include Base
    def to_s;  p.to_s end
    def !@;    self   end
    def depth; 1      end

    class << self
      alias [] new
    end
  end
  P = Atom

  class NEG < Struct.new(:p)
    include Base
    def to_s;  "~#{p}"    end
    def !@;     ~(!p)     end
    def depth;  p.depth+1 end
  end

  class FORM < Struct.new(:vars, :ope)
    include Base
    def initialize(vars, ope)
      self.vars = vars.map { |var| var.is_form?(ope) ? var.vars : var }.flatten
      self.ope = ope
    end

    def to_s; "(#{vars.map(&:to_s).join(_ ope, '|', '&')})" end

    def !@
      if is_or? && (and_form = vars.find { |var| var.is_and? })
        and_form.vars.map { |a| a + FORM.new((vars - [and_form]), :+) }.inject(:*)
      elsif are_there_neg?
        is_or? ? $tout : $utout
      else
        vars.map(&:!).inject(ope)
      end
    end

    def depth;       [p.depth, q.depth].max+1;     end

    def include?(p)
      vars.include?(p)
    end

    private
      def are_there_neg?
        pvars = vars.reject { |var| var.is_neg? }
        nvars = vars.select { |var| var.is_neg? }
        pvars.any? { |pvar|
          nvars.any? { |nvar| nvar.neg?(pvar) }
        }
      end
  end
end
