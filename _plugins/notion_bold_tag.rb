require "cgi"
require "liquid"

module Jekyll
  class NotionBoldTag < ::Liquid::Tag
    def initialize(tag_name, text, tokens)
      super
      @text = text.to_s.strip
    end

    def render(_context)
      %(<span class="notion-bold">#{CGI.escapeHTML(@text)}</span>)
    end
  end
end

::Liquid::Template.register_tag("notion_bold", Jekyll::NotionBoldTag)
