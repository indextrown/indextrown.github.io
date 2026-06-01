require "cgi"

module Jekyll
  module LocalAssetUrlEncoder
    module_function

    def encode_asset_url(url)
      return url unless url.start_with?("/assets/")

      path, suffix = url.split(/([?#].*)/, 2)
      encoded_path = path.split("/", -1).map do |segment|
        next segment if segment.empty?

        decoded_segment =
          begin
            CGI.unescape(segment)
          rescue ArgumentError
            segment
          end

        CGI.escape(decoded_segment).gsub("+", "%20")
      end.join("/")

      "#{encoded_path}#{suffix}"
    end

    def transform(content)
      content.gsub(/(src|href)=["']([^"']+)["']/) do
        attr = Regexp.last_match(1)
        url = Regexp.last_match(2)
        %(#{attr}="#{encode_asset_url(url)}")
      end
    end
  end
end

Jekyll::Hooks.register [:posts, :pages, :documents], :post_render do |doc|
  next unless doc.respond_to?(:output) && doc.output

  doc.output = Jekyll::LocalAssetUrlEncoder.transform(doc.output)
end
