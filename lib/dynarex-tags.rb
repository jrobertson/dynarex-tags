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
    @dxtags = Dynarex.new s, json_out: false
    @dxtags.xslt = @indexfile_xslt if @indexfile_xslt    
    
  end
  
  def add(title: nil, url: nil)
    
    
    puts ('title: ' + title.inspect).debug if @debug
    puts ('url: ' + url.inspect).debug if @debug
    
    h = @dxtags.all.inject({}) {|r,x|  r.merge(x.keyword.downcase => x.count) }
    
    a = title.scan(/(?<=\B#)[\w_]+/).uniq

    a.each do |tag|
      
      t = tag.downcase
      
      h[t] = save_tag(h[t], t, title, url)

      if @dxtags.record_exists? tag then
        @dxtags.update(tag, {count: h[t]})
      else
        @dxtags.create({keyword: tag, count: h[t]}, id: t)
      end

    end    
    
    @dxtags.save @index_filename  

  end
  
  def delete(title)
    
    # find the title in each of the tags file directory
    a = title.downcase.scan(/(?<=#)[\w_]+/)
    
    a.each do |tag|

      puts ("deleting tag: %s for title: %s" % [tag, title]).debug if @debug
      tagfile = File.join(@tags_path, tag + '.xml')
      dx = Dynarex.new(tagfile, json_out: false, autosave: true)      
      rx = dx.find_by_title title
      rx.delete            
      dx.rm if dx.all.empty?

      # find the title in dxtags.xml and delete it       
      entry = @dxtags.find tag
      
      next unless entry
      
      if entry.count == '1' then
        entry.delete
      else
        entry.count = entry.count.to_i - 1
      end
      
    end
    
    @dxtags.save @index_filename 

  end

  def find(tag)

    rx = @dxtags.find tag.downcase
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

    h = @dxtags.all.inject({}) {|r,x|  r.merge(x.keyword.downcase => x.count) }    
    
    dx.all.each do |x|
      
      a = if block_given? then
        blk.call(x)
      else
        x.title.scan(/\B#(\w+)/).map(&:first).uniq\
                        .map{|tag| [tag, x.title, x.url]}
      end

      a.each do |tag, title, url|
        
        t = tag.downcase
        
        h[t] = save_tag(h[t], t, title, url)
        
      end
    end

    
    h.each do |tag, count| 
      
      if @dxtags.record_exists? tag then
        @dxtags.update(tag, {count: count.to_s})
      else
        @dxtags.create({keyword: tag, count: count.to_s}, id: tag.downcase)
      end
      
    end
    
    @dxtags.save @index_filename  

  end  


  private


  def save_tag(tag_count, tag, title, url)
    
    puts ('tag_count: ' + tag_count.inspect).debug if @debug
    tagfile = File.join(@tags_path, tag + '.xml')
    buffer = tag_count ? tagfile : 'items/item(title,url)'

    dx = Dynarex.new(buffer, json_out: false)

    dx.xslt = @tagfile_xslt if @tagfile_xslt
    dx.create(url: url, title: title)

    dx.save tagfile
    dx.all.length
  end
  
end
