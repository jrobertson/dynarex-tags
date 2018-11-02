#!/usr/bin/env ruby

# file: dynarex-tags.rb

require 'dynarex'
require 'fileutils'


class DynarexTags

  def initialize(tags_parent_path, tagfile_xslt: nil, indexfile_xslt: nil)

    @tagfile_xslt, @indexfile_xslt = tagfile_xslt, indexfile_xslt
    
    @tags_path = File.join(tags_parent_path, 'tags')
    FileUtils.mkdir_p @tags_path
    @index_filename = File.join(tags_parent_path, 'dxtags.xml')        

    s = File.exists?(@index_filename) ? \
                                @index_filename : 'tags/tag(keyword,count)'    

    @dxindex = Dynarex.new s, json_out: false    
    @dxindex.xslt = @indexfile_xslt if @indexfile_xslt    
    
  end

  def find(tag)

    rx = @dxindex.find tag.downcase

    if rx then

      tagfile = File.join(@tags_path, tag.downcase + '.xml')
      dx = Dynarex.new(tagfile, json_out: false)
      r = dx.all
      
      def r.to_md()
        self.map {|x| "* [%s](%s)" % [x.title, x.url]}.join("\n")
      end
      
      return r

    end

  end

  def generate(indexfilename='index.xml', &blk)
       
    dx = Dynarex.new indexfilename

    h = @dxindex.all.inject({}) {|r,x|  r.merge(x.keyword => x.count) }    
    
    dx.all.each do |x|
      
      a = if block_given? then
        blk.call(x)
      else
        x.title.scan(/\B#(\w+)/).map(&:first).uniq\
                        .map{|tag| [tag, x.title, x.url]}
      end

      a.each {|tag, title, url| save_tag(h, tag.downcase, title, url)}
    end

    
    h.each do |tag,count| 
      
      if @dxindex.record_exists? tag then
        @dxindex.update(tag, {count: count.to_s})
      else
        @dxindex.create({keyword: tag, count: count.to_s}, id: tag)
      end
      
    end

    @dxindex.save @index_filename    
  end


  private


  def save_tag(h, tag, title, url)
    
    tagfile = File.join(@tags_path, tag + '.xml')
    buffer, h[tag] = h[tag] ? [tagfile, h[tag].succ] \
                                             : ['items/item(title,url)', '1']
    dx = Dynarex.new(buffer, json_out: false)

    dx.xslt = @tagfile_xslt if @tagfile_xslt
    dx.create(url: url, title: title)

    dx.save tagfile
  end
  
end
