module MagicLogic
  module Operator
    [:+, :*].each do |ope|
      define_method(ope) do |q|
        case q
        when Taut ; ope == :+ ? $tout : self
        when UTaut; ope == :+ ? self  : $utout
        when self ; self
        else
          if neg?(q)
            ope == :+ ? $tout : $utout
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
      case self
      when NEG;  p
      when FORM; vars.map(&:~).inject(ope == :+ ? :* : :+)
      else       NEG.new(self)
      end
    end

    def >=(q)
      (~self + q)
    end

    def <=>(q)
      (self >= q) * (q >= self)
    end
  end
end
