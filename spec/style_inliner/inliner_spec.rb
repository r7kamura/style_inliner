require "active_support/core_ext/string/strip"

RSpec.describe StyleInliner::Inliner do
  let(:inliner) do
    described_class.new
  end

  describe "#call" do
    subject do
      inliner.call(html).to_s.gsub(/^ +\n/, "")
    end

    let(:html) do
      <<-EOS.strip_heredoc
        <!DOCTYPE html>
        <html>
          <head>
            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
            <style>
              body {
                background: red;
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
          <body style="background-color: red;">
          </body>
        </html>
      EOS
    end
  end
end
