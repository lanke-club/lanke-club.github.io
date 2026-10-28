# lk-text: the small text format used in _data files and front matter.
#
#   Paragraphs are separated by a blank line; every other line break becomes <br>.
#   **bold**   *italic*   [text](url)   [text](#role-or-setup-id)
#   A line starting with "~ " is greyed out (e.g. abilities a role inherits).
#   A line containing only "\" is an empty line.  \* \[ \] \\ \~ are literal characters.
#
# [text](#id) links to the 角色全册 page that defines that role or setup, so links keep
# working wherever the text is shown.
module Lanke
  module Anchors
    # anchor id => page url, built from _data/rulebook/*.yml and _data/roles.yml
    def self.index(site)
      @index ||= {}
      @index[site.object_id] ||= begin
        roles = site.data['roles'] || {}
        anchor = ->(name) { roles.dig(name, 'anchor') }
        idx = {}
        (site.data['rulebook'] || {}).each_value do |chapter|
          page = chapter['page']
          (chapter['roles'] || []).each { |name| idx[anchor.call(name)] ||= page }
          (chapter['setups'] || []).each do |s|
            idx[s['id']] ||= page
            (s['blocks'] || []).each do |b|
              idx[anchor.call(b['role'])] ||= page if b['role']
              idx[b['anchor']] ||= page if b['anchor']
            end
          end
        end
        idx.delete(nil)
        idx
      end
    end

    def self.resolve(site, href)
      return href unless href.start_with?('#')
      page = index(site)[href[1..]]
      Jekyll.logger.warn 'lktext:', "unknown anchor #{href}" unless page
      page ? "#{page}#{href}" : href
    end
  end

  module LkTextFilter
    def lktext(input)
      return '' if input.nil?
      site = @context.registers[:site]
      input.to_s.strip.split(/\n[ \t]*\n/).map do |para|
        raw = para.split("\n")
        # "\" alone is an empty paragraph (<p><br></p>); inside a paragraph an extra break
        # (as the last line it needs a second <br>, since one trailing <br> does not show)
        lines = raw.each_with_index.map do |l, i|
          next lk_line(l.strip, site) unless l.strip == '\\'
          raw.size == 1 || i == raw.size - 1 ? '<br>' : ''
        end
        "<p>#{lines.join('<br>')}</p>"
      end.join("\n")
    end

    # inline formatting only (no paragraphs)
    def lkinline(input)
      lk_inline(input.to_s, @context.registers[:site])
    end

    private

    def lk_line(line, site)
      dim = line.start_with?('~ ')
      line = line[2..] if dim
      html = lk_inline(line, site)
      dim ? %(<span class="lk-dim">#{html}</span>) : html
    end

    # \* \[ \] \\ \~ are literal characters
    def lk_inline(s, site)
      s = s.gsub(/\\([*\[\]\\~])/) { "\u0000#{Regexp.last_match(1).ord}\u0000" }
      s = s.gsub(/\[([^\]]+)\]\(([^)\s]+)\)/) { %(<a href="#{Anchors.resolve(site, Regexp.last_match(2))}">#{Regexp.last_match(1)}</a>) }
      s = s.gsub(/\*\*(.+?)\*\*/, '<strong>\1</strong>')
      s = s.gsub(/\*(.+?)\*/, '<em>\1</em>')
      s.gsub(/\u0000(\d+)\u0000/) { Regexp.last_match(1).to_i.chr(Encoding::UTF_8) }
    end
  end
end

Liquid::Template.register_filter(Lanke::LkTextFilter)
