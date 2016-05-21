require "style_inliner/declaration_block"
require "style_inliner/rule_set"

module StyleInliner
  class NodeStyleFolding
    CORRESPONDENCE_TABLES = Hash.new({}).merge(
      "blockquote" => {
        "text-align" => "align",
      },
      "body" => {
        "background-color" => "bgcolor",
      },
      "div" => {
        "text-align" => "align",
      },
      "h1" => {
        "text-align" => "align",
      },
      "h2" => {
        "text-align" => "align",
      },
      "h3" => {
        "text-align" => "align",
      },
      "h4" => {
        "text-align" => "align",
      },
      "h5" => {
        "text-align" => "align",
      },
      "h6" => {
        "text-align" => "align",
      },
      "img" => {
        "float" => "align",
      },
      "p" => {
        "text-align" => "align",
      },
      "table" => {
        "background-color" => "bgcolor",
        "background-image" => "background",
      },
      "td" => {
        "background-color" => "bgcolor",
        "text-align" => "align",
        "vertical-align" => "valign",
      },
      "th" => {
        "background-color" => "bgcolor",
        "text-align" => "align",
        "vertical-align" => "valign",
      },
      "tr" => {
        "background-color" => "bgcolor",
        "text-align" => "align",
      },
    )

    # @param node [Nokogiri::XML::Node]
    def initialize(node)
      @node = node
    end

    def call
      update_css_compatible_attributes
      update_style_attribute
    end

    private

    # @return [Hash{String => String}]
    def correspondence_table
      CORRESPONDENCE_TABLES[@node.name]
    end

    # @return [StyleInliner::RuleSet]
    def declaration_block
      @declaration_block ||= DeclarationBlock.new(RuleSet.decode(@node["style"]))
    end

    # @param property_value [String]
    # @return [String]
    def preprocess_attribute_value(property_value)
      property_value.gsub(/url\(['|"](.*)['|"]\)/, '\1').gsub(/;$|\s*!important/, '').strip
    end

    def update_css_compatible_attributes
      correspondence_table.each do |property_name, attribute_name|
        if @node[attribute_name].nil? && !declaration_block.get_property(property_name).empty?
          @node[attribute_name] = preprocess_attribute_value(declaration_block.get_property(property_name))
          declaration_block.delete_property(property_name)
        end
      end
    end

    def update_style_attribute
      if (value = declaration_block.to_s).empty?
        @node.remove_attribute("style")
      else
        @node["style"] = value
      end
    end
  end
end
