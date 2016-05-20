require "style_inliner/document"

module StyleInliner
  class Inliner
    # @param html [String]
    # @return [Nokogiri::XML::Node]
    def call(html)
      Document.new(html).inline
    end
  end
end
