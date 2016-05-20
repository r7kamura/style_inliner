require "css_parser"
require "nokogiri"
require "style_inliner/declaration_block"
require "style_inliner/rule_set"
require "style_inliner/selector"

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
        if Selector.new(selector).unmergeable?
          css_parser_for_unmergeable_rules.add_rule_set!(
            ::CssParser::RuleSet.new(selector, declarations),
            media_types,
          )
        else
          root.search(selector).each do |node|
            if node.element?
              node["style"] = "#{node['style']} #{RuleSet.new(declarations: declarations, specificity: specificity).encode}"
            end
          end
        end
      end
    end

    # @return [Nokogiri::XML::Node]
    def root
      @root ||= ::Nokogiri.HTML(@html)
    end
  end
end
