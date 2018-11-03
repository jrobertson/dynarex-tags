#!/usr/bin/env ruby

# file: dynarex-tags.rb

require 'dynarex'
require 'fileutils'


class DynarexTags
  include RXFHelperModule
  using ColouredText

  def initialize(tags_parent_path, tagfile_xslt: nil, indexfile_xslt: nil, 
                 debug: false)

    puts ('tags_parent_path: '  + tags_parent_path).debug if debug
    @filepath = tags_parent_path
    
    @tagfile_xslt, @indexfile_xslt, @debug = tagfile_xslt, 
        indexfile_xslt, debug
    
    @tags_path = File.join(tags_parent_path, 'tags')
    FileX.mkdir_p @tags_path
    @index_filename = File.join(tags_parent_path, 'dxtags.xml')        

    s = FileX.exists?(@index_filename) ? \
                                @index_filename : 'tags/tag(keyword,count)'    

    puts ('dxtags filepath: ' + s.inspect).debug if debug
    @dxindex = Dynarex.new s, json_out: false    
    @dxindex.xslt = @indexfile_xslt if @indexfile_xslt    
    
  end

  def find(tag)

    rx = @dxindex.find tag.downcase
    puts ('rx: ' + rx.inspect).debug if @debug
    
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

  def generate(indexfilename=File.join(@filepath, 'index.xml'), &blk)
       
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
