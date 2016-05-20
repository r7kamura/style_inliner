module StyleInliner
  class DeclarationBlock
    # @param rule_sets [Array<StyleInliner::RuleSet>]
    def initialize(rule_sets)
      @rule_sets = rule_sets
    end

    # @return [String]
    def to_s
      merged_rule_set.declarations_to_s.gsub('"', "'").split(/;(?![^(]*\))/).map(&:strip).sort.join("; ") + ";"
    end

    private

    # @return [CssParser::RuleSet]
    def merged_rule_set
      ::CssParser.merge(
        @rule_sets.map do |rule_set|
          ::CssParser::RuleSet.new(
            nil,
            rule_set.declarations,
            rule_set.specificity,
          )
        end
      ).tap(&:expand_shorthand!)
    end
  end
end
