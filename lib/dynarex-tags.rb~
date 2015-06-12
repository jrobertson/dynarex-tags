#!/usr/bin/env ruby

# file: dynarex-tags.rb

require 'dynarex'
require 'fileutils'

class DynarexTags

  def initialize(tags_parent_path)

    @tags_path = File.join(tags_parent_path, 'tags')
    FileUtils.mkdir_p @tags_path
    @index_filename = File.join(tags_parent_path, 'dxtags.xml')
    
  end

  def generate(category_url, &blk)

    h = {}
    dx = Dynarex.new category_url

    dx.all.each do |x|
      
      a = if block_given? then
        blk.call(x)
      else
        x.title.scan(/\B#(\w+)/).map(&:first).uniq\
                        .map{|tag| [tag, x.title, x.url]}
      end

      a.each {|tag, title, url| save_tag(h, tag, title, url)}
    end

    save_dynarex_index(h)
  end


  private

  def save_dynarex_index(h)
    
    s = File.exists?(@index_filename) ? \
                                @index_filename : 'tags/tag(keyword,count)'
    dx = Dynarex.new s
    h.each {|tag,count| dx.create keyword: tag, count: count.to_s}
    
    dx.save @index_filename
  end

  def save_tag(h, tag, title, url)

    tagfile = tag + '.xml'    
    buffer, h[tag] = h[tag] ? [tagfile, h[tag].succ] \
                                                : ['items/item(title,url)', '1']
    Dynarex.new(buffer).create(url: url, title: title)\
                                         .save File.join(@tags_path, tagfile)
  end
  
end