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
       
    s = File.exists?(@index_filename) ? \
                                @index_filename : 'tags/tag(keyword,count)'
    dxindex = Dynarex.new s    
    h = dxindex.all.inject({}) {|r,x|  r.merge(x.keyword => x.count) }
    
    dx = Dynarex.new category_url

    dx.all.each do |x|
      
      a = if block_given? then
        blk.call(x)
      else
        x.title.scan(/\B#(\w+)/).map(&:first).uniq\
                        .map{|tag| [tag, x.title, x.url]}
      end

      a.each {|tag, title, url| save_tag(h, tag.downcase, title, url)}
    end
    
    h.each {|tag,count| dxindex.create keyword: tag, count: count.to_s}    

    dxindex.save @index_filename    
  end


  private


  def save_tag(h, tag, title, url)

    tagfile = File.join(@tags_path, tag + '.xml')
    buffer, h[tag] = h[tag] ? [tagfile, h[tag].succ] \
                                             : ['items/item(title,url)', '1']

    Dynarex.new(buffer).create(url: url, title: title).save tagfile
  end
  
end