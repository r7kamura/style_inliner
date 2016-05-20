require "active_support/core_ext/string/strip"

RSpec.describe StyleInliner::Document do
  let(:document) do
    described_class.new(html)
  end

  describe "#inline" do
    subject do
      document.inline.to_s.gsub(/^ +\n/, "")
    end

    context "with style element in head element" do
      let(:html) do
        <<-EOS.strip_heredoc
          <!DOCTYPE html>
          <html>
            <head>
              <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
              <style>
                body {
                  color: red;
                }
              </style>
            </head>
            <body>
            </body>
          </html>
        EOS
      end

      it "inlines style element into style attributes" do
        is_expected.to eq <<-EOS.strip_heredoc
          <!DOCTYPE html>
          <html>
            <head>
              <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
            </head>
            <body style="color: red;">
            </body>
          </html>
        EOS
      end
    end

    context "with style with wildcard element selector" do
      let(:html) do
        <<-EOS.strip_heredoc
          <!DOCTYPE html>
          <html>
            <head>
              <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
              <style>
                * {
                  color: red;
                }
              </style>
            </head>
            <body>
            </body>
          </html>
        EOS
      end

      it "does not apply styles to elements within head element" do
        is_expected.to eq <<-EOS.strip_heredoc
          <!DOCTYPE html>
          <html style="color: red;">
            <head>
              <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
            </head>
            <body style="color: red;">
            </body>
          </html>
        EOS
      end
    end

    context "with ID selector and multiple elements that have same ID" do
      let(:html) do
        <<-EOS.strip_heredoc
          <!DOCTYPE html>
          <html>
            <head>
              <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
              <style>
                #example {
                  color: red;
                }
              </style>
            </head>
            <body>
              <p id="example">example1</p>
              <p id="example">example2</p>
            </body>
          </html>
        EOS
      end

      it "applies styles to all matched elements" do
        is_expected.to eq <<-EOS.strip_heredoc
          <!DOCTYPE html>
          <html>
            <head>
              <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
            </head>
            <body>
              <p id="example" style="color: red;">example1</p>
              <p id="example" style="color: red;">example2</p>
            </body>
          </html>
        EOS
      end
    end
  end
end
