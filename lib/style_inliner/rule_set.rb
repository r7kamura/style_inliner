module StyleInliner
  class RuleSet
    PATTERN = /\[SPEC\=(\d+)\[(.[^\]]*)\]\]/

    attr_reader :declarations
    attr_reader :specificity

    class << self
      # @param source [String]
      def decode(source)
        source.scan(PATTERN).map do |specificity, declarations|
          new(
            declarations: declarations,
            specificity: specificity.to_i,
          )
        end
      end
    end

    # @param specificity [Integer] e.g. `1`
    # @param declarations [String] e.g. `"background: red; color: yellow;"`
    def initialize(declarations:, specificity:)
      @declarations = declarations
      @specificity = specificity
    end

    # @return [String]
    def encode
      "[SPEC=#{@specificity}[#{@declarations}]]"
    end
  end
end
