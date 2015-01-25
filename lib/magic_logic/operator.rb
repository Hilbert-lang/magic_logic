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
end
