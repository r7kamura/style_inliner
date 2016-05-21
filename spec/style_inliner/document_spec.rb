require "active_support/core_ext/string/strip"

RSpec.describe StyleInliner::Document do
  let(:document) do
    described_class.new(html, **options)
  end

  let(:options) do
    {}
  end

  describe "#inline" do
    subject do
      document.inline.to_s.gsub(/^ +\n/, "")
    end

    context "with style element" do
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
            <body style="color: red">
            </body>
          </html>
        EOS
      end
    end

    context "with !important declaration" do
      let(:html) do
        <<-EOS.strip_heredoc
          <!DOCTYPE html>
          <html>
            <head>
              <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
              <style>
                body {
                  color: red !important;
                }
              </style>
            </head>
            <body>
            </body>
          </html>
        EOS
      end

      it "preserves it" do
        is_expected.to eq <<-EOS.strip_heredoc
          <!DOCTYPE html>
          <html>
            <head>
              <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
            </head>
            <body style="color: red !important">
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
          <html style="color: red">
            <head>
              <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
            </head>
            <body style="color: red">
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
              <p id="example" style="color: red">example1</p>
              <p id="example" style="color: red">example2</p>
            </body>
          </html>
        EOS
      end
    end

    context "with unmergeable styles" do
      let(:html) do
        <<-EOS.strip_heredoc
          <!DOCTYPE html>
          <html>
            <head>
              <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
              <style>
                a:hover {
                  color: red;
                }
              </style>
            </head>
            <body>
              <a>example</a>
            </body>
          </html>
        EOS
      end

      it "prepends style element into body element for them" do
        is_expected.to eq <<-EOS.strip_heredoc
          <!DOCTYPE html>
          <html>
            <head>
              <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
            </head>
            <body>
          <style>
          a:hover {
          color: red;
          }
          </style>
              <a>example</a>
            </body>
          </html>
        EOS
      end
    end

    context "with :link pseudo class" do
      let(:html) do
        <<-EOS.strip_heredoc
          <!DOCTYPE html>
          <html>
            <head>
              <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
              <style>
                a:link {
                  color: red;
                }
              </style>
            </head>
            <body>
              <a>example</a>
            </body>
          </html>
        EOS
      end

      it "ignores it" do
        is_expected.to eq <<-EOS.strip_heredoc
          <!DOCTYPE html>
          <html>
            <head>
              <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
            </head>
            <body>
              <a style="color: red">example</a>
            </body>
          </html>
        EOS
      end
    end

    context "with styles compatible with element attributes" do
      let(:html) do
        <<-EOS.strip_heredoc
          <!DOCTYPE html>
          <html>
            <head>
              <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
              <style>
                td {
                  background-color: red !important;
                }
              </style>
            </head>
            <body>
              <table>
                <tr>
                  <td>example</td>
                </tr>
              </table>
            </body>
          </html>
        EOS
      end

      it "replaces it with attributes without !important" do
        is_expected.to eq <<-EOS.strip_heredoc
          <!DOCTYPE html>
          <html>
            <head>
              <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
            </head>
            <body>
              <table>
                <tr>
                  <td bgcolor="red">example</td>
                </tr>
              </table>
            </body>
          </html>
        EOS
      end
    end

    context "with styles compatible with element attributes on disabled" do
      let(:html) do
        <<-EOS.strip_heredoc
          <!DOCTYPE html>
          <html>
            <head>
              <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
              <style>
                td {
                  background-color: red;
                }
              </style>
            </head>
            <body>
              <table>
                <tr>
                  <td>example</td>
                </tr>
              </table>
            </body>
          </html>
        EOS
      end

      let(:options) do
        super().merge(replace_properties_to_attributes: false)
      end

      it "does not replaces it" do
        is_expected.to eq <<-EOS.strip_heredoc
          <!DOCTYPE html>
          <html>
            <head>
              <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
            </head>
            <body>
              <table>
                <tr>
                  <td style="background-color: red">example</td>
                </tr>
              </table>
            </body>
          </html>
        EOS
      end
    end
  end
end
