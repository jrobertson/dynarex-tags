#!/usr/bin/env ruby

# file: dynarex-tags.rb

require 'dynarex'
require 'fileutils'

class DynarexTags

  def initialize(tags_path)

    FileUtils.mkdir_p tags_path
    Dir.chdir tags_path
    @index_filename = File.join(tags_path, '_dynarextags.xml')
  end

  def generate(category_url)

    h = {}
    category_dynarex = Dynarex.new category_url

    category_dynarex.to_h.each do |item| 

      title, url = item.values[0..1]
      title.scan(/#(\w+)/).flatten.each {|tag| save_tag(h, tag, title, url)}
    end

    save_dynarex_index(h)
  end

  def save_title_tags(title, url)

    if File.exists? @index_filename then
      dynarex = Dynarex.new @index_filename
    else
      dynarex = Dynarex.new('tags/tag(keyword,count)')
      dynarex.save @index_filename, pretty: true
    end

    h = dynarex.flat_records.inject({}) do |r,x| 
      r.merge({x[:keyword] => x[:count].to_i})
    end

    title.scan(/#(\w+)/).flatten.each {|tag| save_tag(h,tag, title, url)}
    save_dynarex_index(h)
  end

  private

  def save_dynarex_index(h)
    
    dynarex = Dynarex.new('tags/tag(keyword,count)')
    h.each {|tag,count| dynarex.create keyword: tag, count: count.to_s}
    dynarex.save @index_filename, pretty: true      
  end

  def save_tag(h, tag, title, url)

    rec = h[tag]
    tagfile = tag + '.xml'

    if rec then

      h[tag] += 1
      dyn = Dynarex.new(tagfile)

    else

      h[tag] = 1
      dyn = Dynarex.new('items/item(title,url)')
    end

    dyn.create(url: url, title: title)
    dyn.save tagfile, pretty: true
  end
  
end