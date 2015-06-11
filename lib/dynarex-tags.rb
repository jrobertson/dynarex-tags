#!/usr/bin/env ruby

# file: dynarex-tags.rb

require 'dynarex'
require 'fileutils'

class DynarexTags

  def initialize(tags_parent_path)

    FileUtils.mkdir_p File.join(tags_parent_path, 'tags')
    Dir.chdir File.join(tags_parent_path, 'tags')
    @index_filename = File.join(tags_parent_path, 'dxtags.xml')
  end

  def generate(category_url)

    h = {}
    dx = Dynarex.new category_url

    dx.all.each do |x|
      
      x.title.scan(/\B#(\w+)/).map(&:first).uniq\
                                 .each {|tag| save_tag(h, tag, x.title, x.url)}
    end

    save_dynarex_index(h)
  end


  private

  def save_dynarex_index(h)
    
    dx = Dynarex.new('tags/tag(keyword,count)')
    h.each {|tag,count| dx.create keyword: tag, count: count.to_s}
    dx.save @index_filename
  end

  def save_tag(h, tag, title, url)

    tagfile = tag + '.xml'    
    buffer, h[tag] = h[tag] ? [tagfile, h[tag].succ] \
                                                : ['items/item(title,url)', '1']
    Dynarex.new(buffer).create(url: url, title: title).save tagfile
  end
  
end