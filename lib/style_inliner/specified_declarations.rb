module StyleInliner
  class SpecifiedDeclarations
    # @param source [String]
    def initialize(source)
      @source = source
    end

    # @return [Array<String>]
    def to_attributes
      merged_rule_set.declarations_to_s.gsub('"', "'").split(/;(?![^(]*\))/).map(&:strip).sort
    end

    private

    # @return [CssParser::RuleSet]
    def merged_rule_set
      merged_rule_set = ::CssParser.merge(rule_sets)
      merged_rule_set.expand_shorthand!
      merged_rule_set
    end

    # @return [Array<CssParser::RuleSet>]
    def rule_sets
      @source.scan(/\[SPEC\=(\d+)\[(.[^\]]*)\]\]/).map do |declaration|
        ::CssParser::RuleSet.new(nil, declaration[1], declaration[0])
      end
    end
  end
end
