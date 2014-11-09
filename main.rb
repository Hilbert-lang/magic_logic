module World
  class Entity
  end
end

$world = World::Entity

module World
  class Entity
    @@truth = %i(atom negative disjunction conjunction universal).reduce({}) do |hash, k|
      hash[k] = []
      hash
    end
    class << self
      def <<(logic)
        case logic
        when Atom        then @@truth[:atoms]        << logic
        when Negative    then @@truth[:negative]     << logic
        when Disjunction then @@truth[:disjunction]  << logic
        when Conjunction then @@truth[:conjunction]  << logic
        when Universal   then @@truth[:universal]    << logic
        end
      end

      # Accesor
      def truth
        @@truth
      end
    end
  end
end


class Atom < Logic
  attr_accessor :pred, :term
  class << self
    def def!(pred, term)
      $world << new(pred, term)
    end
  end
  def initialize(pred, term)
    @pred, @term = pred, term
  end

  def eval!
    $world
  end
end

class Universal < Logic
  attr_accessor :logic
  class << self
    def def!(logic)
      $world << new(logic)
    end
  end

  def initialize(logic)
    @logic = logic
  end

  def eval!
  end
end

class Negative < Logic
  attr_accessor :logic

  class << self
    def def!(logic)
      $world << new(logic)
    end
  end

  def initialize(logic)
    @logic = logic
  end

  def eval!
  end
end

class Disjunction < Logic
  attr_accessor :logic1, :logic2

  class << self
    def def!(logic1, logic2)
      $world << new(logic1, logic2)
    end
  end

  def initialize(logic1, logic2)
    @logic1, @logic2 = logic1, logic2
  end

  def eval!
  end
end

class Conjunction < Logic
  attr_accessor :logic1, :logic2

  class << self
    def def!(logic1, logic2)
      $world << new(logic1, logic2)
    end
  end

  def initialize(logic1, logic2)
    @logic1, @logic2 = logic1, logic2
  end

  def eval!
  end
end
