# Image helpers for files uploaded the WordPress way: an original (foo.png) plus resized
# copies next to it (foo-150x150.png, foo-300x300.png, …).
#
#   {{ src | wp_srcset }}   "foo.png 1024w, foo-300x300.png 300w, …" ("" if there are no copies)
#   {{ src | wp_width }} / {{ src | wp_height }}   pixel size of the file
#   {{ src | wp_size: 150 }} path of the 150px copy (falls back to the original)
module Lanke
  module ImageFilters
    # WordPress order: the image itself, then medium (300), large (1024), thumbnail (150),
    # medium_large (768), 1536, 2048, then the original. (Browsers can pick differently by order.)
    WP_ORDER = [300, 1024, 150, 768, 1536, 2048].freeze

    def wp_srcset(src)
      original = Lanke::ImageFilters.original(src)
      variants = Lanke::ImageFilters.variants(site_source, original)
      return '' if variants.empty?
      all = variants.sort_by { |_, w| WP_ORDER.index(w) || 99 } + [[original, Lanke::ImageFilters.width(site_source, original)]]
      own = all.find { |p, _| p == src.to_s }
      ([own] + (all - [own])).compact.map { |p, w| "#{p} #{w}w" }.join(', ')
    end

    # foo-150x150.png -> foo.png (when foo.png exists)
    def self.original(src)
      m = src.to_s.match(/\A(.*)-\d+x\d+(\.\w+)\z/)
      m ? "#{m[1]}#{m[2]}" : src.to_s
    end

    def wp_width(src)
      Lanke::ImageFilters.dims(site_source, src)[0]
    end

    def wp_height(src)
      Lanke::ImageFilters.dims(site_source, src)[1]
    end

    def wp_size(src, size)
      hit = Lanke::ImageFilters.variants(site_source, src).find { |_, w| w == size.to_i }
      hit ? hit[0] : src
    end

    def self.variants(root, src)
      base, ext = src.to_s.match(/\A(.*)(\.\w+)\z/)&.captures
      return [] unless base && src.start_with?('/')
      Dir.glob(File.join(root, "#{base}-*x*#{ext}")).filter_map do |f|
        m = File.basename(f).match(/-(\d+)x(\d+)#{Regexp.escape(ext)}\z/)
        next unless m && File.basename(f) == "#{File.basename(base)}-#{m[1]}x#{m[2]}#{ext}"
        [f.delete_prefix(root), m[1].to_i]
      end.sort_by { |_, w| -w }
    end

    def self.width(root, src)
      dims(root, src)[0]
    end

    # [width, height] from the PNG/JPEG/GIF header (no image library needed)
    def self.dims(root, src)
      path = File.join(root, src.to_s)
      return [0, 0] unless File.file?(path)
      File.open(path, 'rb') do |f|
        head = f.read(26)
        if head.start_with?("\x89PNG".b)
          head[16, 8].unpack('NN')
        elsif head.start_with?('GIF')
          head[6, 4].unpack('vv')
        elsif head.start_with?("\xFF\xD8".b)
          f.seek(2)
          loop do
            marker, len = f.read(4).unpack('nn')
            if (0xFFC0..0xFFCF).cover?(marker) && ![0xFFC4, 0xFFC8, 0xFFCC].include?(marker)
              h, w = f.read(5).unpack('Cnn')[1, 2]
              return [w, h]
            end
            f.seek(len - 2, IO::SEEK_CUR)
          end
        else
          [0, 0]
        end
      end
    end

    private

    def site_source
      @context.registers[:site].source
    end
  end
end

Liquid::Template.register_filter(Lanke::ImageFilters)
