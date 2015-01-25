module MagicLogic
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
end
