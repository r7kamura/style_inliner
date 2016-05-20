module StyleInliner
  class Selector
    # @param string [String]
    def initialize(string)
      @string = string
    end

    # @todo
    # @return [false, true]
    def unmergeable?
      false
    end
  end
end
