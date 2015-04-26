# Title: Jekyll Icon Tag
#
# Description: Use SVG icons in Jekyll.
#
# Syntax:  {% icon [preset or WxH] path/to/icon.svg [attr="value"] %}
# Example: {% icon calendar.svg alt="Click to view Calendar." %}
#          {% icon gallery calendar.svg alt="Click to view Calendar." class="cal-icon" data-special %}
#          {% icon 350xAUTO calendar.svg alt="Click to view Calendar." class="cal-icon" data-special %}
#

require 'fileutils'
require 'pathname'
require 'nokogiri'

module Jekyll

  class Icon < Liquid::Tag

    def initialize(tag_name, markup, tokens)
      @markup = markup
      super
    end

    def render(context)
      # Render any liquid variables in tag arguments and unescape template code
      render_markup = Liquid::Template.parse(@markup).render(context).gsub(/\\\{\\\{|\\\{\\%/, '\{\{' => '{{', '\{\%' => '{%')

      # # Gather settings
      site = context.registers[:site]
      if site.config['icon']
        settings = site.config['icon']
      else
        settings = {}
        settings['presets'] = {}
      end

      markup = /^(?:(?<preset>[^\s.:\/]+)\s+)?(?<icon_src>[^\s]+\.[a-zA-Z0-9]{3,4})\s*(?<html_attr>[\s\S]+)?$/.match(render_markup)
      preset = settings['presets'][ markup[:preset] ]

      raise "Icon Tag can't read this tag. Try {% icon [preset or WxH] path/to/icon.svg [attr=\"value\"] %}." unless markup

      # Assign defaults
      settings['source'] ||= '.'

      # For now use the source folder.
      settings['output'] ||= settings['source']
      # settings['output'] ||= 'generated'

      # Prevent Jekyll from erasing our generated files
      site.config['keep_files'] << settings['output'] unless site.config['keep_files'].include?(settings['output'])

      # Process instance
      instance = if preset
        {
          :width => preset['width'],
          :height => preset['height'],
          :src => markup[:icon_src]
        }
      elsif dim = /^(?:(?<width>\d+)|auto)(?:x)(?:(?<height>\d+)|auto)$/i.match(markup[:preset])
        {
          :width => dim['width'],
          :height => dim['height'],
          :src => markup[:icon_src]
        }
      else
        { :src => markup[:icon_src] }
      end

      # Process HTML attributes
      html_attr = if markup[:html_attr]
        Hash[ *markup[:html_attr].scan(/(?<attr>[^\s="]+)(?:="(?<value>[^"]+)")?\s?/).flatten ]
      else
        {}
      end

      if preset && preset['width']
        html_attr = html_attr.merge({
          :width => preset['width'],
        })
      end

      if preset && preset['height']
        html_attr = html_attr.merge({
          :height => preset['height'],
        })
      end

      if preset && preset['attr']
        html_attr = preset['attr'].merge(html_attr)
      end

      html_attr_string = html_attr.inject('') { |string, attrs|
        if attrs[1]
          string << "#{attrs[0]}=\"#{attrs[1]}\" "
        else
          string << "#{attrs[0]} "
        end
      }

      # Raise some exceptions before we start expensive processing
      raise "Icon Tag can't find the \"#{markup[:preset]}\" preset. Check icon: presets in _config.yml for a list of presets." unless preset || dim ||  markup[:preset].nil?


      image_source_path = File.join(site.source, instance[:src])

      if image_source_path == '/var/www/dgthree-local/images/icons/ignore.svg'
        puts "Playing with: #{image_source_path}"

        file = File.open(image_source_path)
        begin
          # Make sure we have valid SVG files
          doc = Nokogiri::XML.parse(file) { |config| config.strict }
          svg_document = doc.search('svg')[0]
        rescue Nokogiri::XML::SyntaxError => e
          puts "SyntaxError: #{image_source_path}: #{e}"
        end
        file.close()

        html_attr = {}
        svg_document.each do |node|
          if ['viewBox', 'height', 'width'].include? node[0]
            html_attr[node[0]] = node[1]
          end
        end

        svg_document.element_children.each do |node|
          puts "Inner: " + node.class.to_s
        end



        the_sprite = get_sprite_document()

        icon_symbol = Nokogiri::XML::Node.new 'symbol', the_sprite.doc.root


        ext = File.extname(instance[:src])
        basename = File.basename(instance[:src], ext)
        icon_symbol['id'] = basename
        the_sprite.doc.root.add_child(icon_symbol)

        # the_sprite.xpath('/svg').each do |node|
        #   pust node.to_s
        #   symbol = Nokogiri::XML::Node.new "symbol", the_sprite
        #   symbol.content = "10"
        #   node.add_child(symbol)
        # end

        # puts the_sprite.to_xml(:indent => 0)
        puts the_sprite.to_xml()



        # puts "Debug: " + @sprite_svg_element.class.to_s
        # Retrieve the root node.

        #svg_elem = doc.parse()
        # puts "Debug: " + svg_elem.class.to_s

        #url = 'http://upload.wikimedia.org/wikipedia/commons/e/e9/Pepsi_logo_2008.svg'
        #doc = Nokogiri::HTML(open(url))
        #puts doc.xpath('//*[contains(@style,"fill")]').map{|e| e[:style][/fill:([^;]*)/, 1]}.uniq

        'yyy'

        # puts @doc.xpath('//path').to_html
      end

      # Generate resized images
      # generated_src = get_inline_svg(instance, site.source, site.dest, settings['source'], settings['output'])
      # unless generated_src
      #   return
      # end

      # generated_src = File.join(site.baseurl, generated_src) unless site.baseurl.empty?
      # Return the markup!
      # "<img src=\"#{generated_src}\" #{html_attr_string}>"
    end

    def get_sprite_document()
      # @TODO: First check if the document doesn't already exists.

      builder = Nokogiri::XML::Builder.new do |xml|
        # Add the DOCTYPE.
        xml.doc.create_internal_subset(
          'svg',
          '-//W3C//DTD SVG 1.1//EN',
          'http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd'
        )

        # Create a new SVG tag.
        xml.svg('xmlns' => 'http://www.w3.org/2000/svg') do |parent|
          @sprite_svg_element = parent
        end
      end

      return builder
    end

    def get_inline_svg(instance, site_source, site_dest, image_source, image_dest)

      image_source_path = File.join(site_source, image_source, instance[:src])
      unless File.exists?image_source_path
        puts "Missing: #{image_source_path}"
        return false
      end

      image_dir = File.dirname(instance[:src])
      ext = File.extname(instance[:src])
      basename = File.basename(instance[:src], ext)

      if ext != '.svg'
        puts "Only SVG icons are supported: #{image_source_path}"
        return false
      end

      gen_name = "#{basename}#{ext}"
      gen_dest_dir = File.join(site_dest, image_dest, image_dir)

      # Return path relative to the site root for html
      # @TODO: Implement proper inline SVG with `<use>`
      Pathname.new(File.join('/', image_dest, image_dir, gen_name)).cleanpath
    end
  end
end



Liquid::Template.register_tag('icon', Jekyll::Icon)


