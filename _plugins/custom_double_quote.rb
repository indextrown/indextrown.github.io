module Jekyll
  module CustomDoubleQuote
    module_function

    def transform(content)
      lines = content.lines
      out = []
      in_block = false
      in_fence = false

      lines.each do |line|
        stripped = line.lstrip

        if stripped.start_with?("```") || stripped.start_with?("~~~")
          if in_block
            out << "</blockquote>\n"
            in_block = false
          end
          in_fence = !in_fence
          out << line
          next
        end

        if !in_fence && line.match?(/^blue\s*>\s?/)
          unless in_block
            out << "<blockquote class=\"custom-double-quote\" markdown=\"1\">\n"
            in_block = true
          end
          out << "#{line.sub(/^blue\s*>\s?/, '')}"
        else
          if in_block
            out << "</blockquote>\n"
            in_block = false
          end
          out << line
        end
      end

      out << "</blockquote>\n" if in_block
      out.join
    end
  end
end

Jekyll::Hooks.register [:posts, :pages, :documents], :pre_render do |doc|
  next unless doc.respond_to?(:content) && doc.content

  doc.content = Jekyll::CustomDoubleQuote.transform(doc.content)
end
