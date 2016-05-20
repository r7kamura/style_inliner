require "css_parser"
require "nokogiri"
require "style_inliner/declaration_block"
require "style_inliner/rule_set"

module StyleInliner
  class Document
    # @param html [String]
    def initialize(html)
      @html = html
    end

    # @return [Nokogiri::XML::Node]
    def inline
      load_styles_from_html
      merge_styles_into_each_element
      fold_style_attributes
      root
    end

    private

    # @param selector [Stirng]
    # @param declarations [String]
    # @param media_types [Array<Symbol>]
    def add_unmergeable_rule_set(selector, declarations, media_types)
      css_parser_for_unmergeable_rules.add_rule_set!(
        ::CssParser::RuleSet.new(selector, declarations),
        media_types,
      )
    end

    # @param node [Nokogiri::XML::Node]
    # @return [false, true]
    def check_node_stylability(node)
      node.element? && node.name != "head" && node.parent.name != "head"
    end

    # @todo
    # @param selector [String]
    # @return [false, true]
    def check_selector_mergeability(selector)
      true
    end

    # @return [CssParser::Parser]
    def css_parser_for_mergeable_rules
      @css_parser_for_mergeable_rules ||= ::CssParser::Parser.new
    end

    # @return [CssParser::Parser]
    def css_parser_for_unmergeable_rules
      @css_parser_for_unmergeable_rules ||= ::CssParser::Parser.new
    end

    def fold_style_attributes
      root.search("*[@style]").each do |node|
        node["style"] = DeclarationBlock.new(RuleSet.decode(node["style"])).to_s
      end
    end

    # Load styles from <style> and <link> elements from a given HTML document.
    def load_styles_from_html
      load_styles_from_link_elements
      load_styles_from_style_elements
    end

    # @todo
    def load_styles_from_link_elements
    end

    def load_styles_from_style_elements
      root.search("style").each do |style_node|
        css_parser_for_mergeable_rules.add_block!(style_node.inner_html)
        style_node.remove
      end
    end

    def merge_styles_into_each_element
      css_parser_for_mergeable_rules.each_selector(:all) do |selector, declarations, specificity, media_types|
        if check_selector_mergeability(selector)
          root.search(selector).each do |node|
            if check_node_stylability(node)
              push_encoded_rule_set_into_style_attribute(node, declarations, specificity)
            end
          end
        else
          add_unmergeable_rule_set(selector, declarations, media_types)
        end
      end
    end

    # @param node [Nokogiri::XML::Node]
    # @param declarations [String]
    # @param specificity [Integer]
    def push_encoded_rule_set_into_style_attribute(node, declarations, specificity)
      node["style"] = "#{node['style']} #{RuleSet.new(declarations: declarations, specificity: specificity).encode}"
    end

    # @return [Nokogiri::XML::Node]
    def root
      @root ||= ::Nokogiri.HTML(@html)
    end
  end
end
