require "css_parser"
require "nokogiri"
require "style_inliner/node_style_folding"
require "style_inliner/rule_set"

module StyleInliner
  class Document
    UNMERGEABLE_PSEUDO_CLASS_NAMES = %w(
      active
      after
      before
      first-letter
      first-line
      focus
      hover
      selection
      target
      visited
    )

    # @param html [String]
    def initialize(html)
      @html = html
    end

    # @return [Nokogiri::XML::Node]
    def inline
      load_styles_from_html
      merge_styles_into_each_element
      fold_style_attributes
      append_style_element_for_unmergeable_rule_sets
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

    def append_style_element_for_unmergeable_rule_sets
      rule_set_string = css_parser_for_unmergeable_rules.to_s
      unless rule_set_string.empty?
        if (body_node = root.at("body"))
          body_node.prepend_child(
            ::Nokogiri::XML.fragment("<style>\n#{rule_set_string}</style>")
          )
        end
      end
    end

    # @param node [Nokogiri::XML::Node]
    # @return [false, true]
    def check_node_stylability(node)
      node.element? && node.name != "head" && node.parent.name != "head"
    end

    # @param selector [String]
    # @return [false, true]
    def check_selector_mergeability(selector)
      !selector.start_with?("@") && !UNMERGEABLE_PSEUDO_CLASS_NAMES.any? { |name| selector.include?(":#{name}") }
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
        NodeStyleFolding.new(node).call
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
          root.search(strip_link_pseudo_class(selector)).each do |node|
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
      rule_set = RuleSet.new(declarations: declarations, specificity: specificity)
      node["style"] = "#{node['style']} #{rule_set.encode}"
    end

    # @return [Nokogiri::XML::Node]
    def root
      @root ||= ::Nokogiri.HTML(@html)
    end

    # @param selector [String]
    # @return [String]
    def strip_link_pseudo_class(selector)
      selector.gsub(":link", "")
    end
  end
end
