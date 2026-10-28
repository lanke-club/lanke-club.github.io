# Generates paginated category archives: /category/<slug>/ and /category/<slug>/page/N/.
# Configure in _config.yml under `archives:`. A post belongs to an archive when one of its
# `categories` is the slug or a sub-category of it ("圆月大会/第二届圆月大会" is in "圆月大会").
module Lanke
  class ArchivePage < Jekyll::Page
    def initialize(site, slug, title, posts, num, total)
      @site = site
      @base = site.source
      @dir = num == 1 ? "category/#{slug}" : "category/#{slug}/page/#{num}"
      @name = 'index.html'
      process(@name)
      @content = ''
      first = "/category/#{slug}/"
      page_url = ->(n) { n == 1 ? first : "#{first}page/#{n}/" }
      @data = {
        'layout' => 'archive',
        'title' => title,
        'posts' => posts,
        'page_num' => num,
        'pages' => (1..total).map { |n| { 'num' => n, 'url' => page_url.call(n) } },
        'prev_url' => num > 1 ? page_url.call(num - 1) : nil,
        'next_url' => num < total ? page_url.call(num + 1) : nil
      }
    end
  end

  class ArchiveGenerator < Jekyll::Generator
    safe true
    priority :low

    def generate(site)
      cfg = site.config['archives'] || {}
      per = (cfg['per_page'] || 10).to_i
      (cfg['categories'] || {}).each do |slug, title|
        posts = site.posts.docs.select do |p|
          Array(p.data['categories']).any? { |c| c == slug || c.start_with?("#{slug}/") }
        end.sort_by { |p| p.date }.reverse
        chunks = posts.each_slice(per).to_a
        chunks = [[]] if chunks.empty?
        chunks.each_with_index do |chunk, i|
          site.pages << ArchivePage.new(site, slug, title, chunk, i + 1, chunks.size)
        end
      end
    end
  end
end
