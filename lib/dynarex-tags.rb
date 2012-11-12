#!/usr/bin/env ruby

# file: dynarex-tags.rb

require 'dynarex'
require 'fileutils'

class DynarexTags

  def initialize(tags_path, category_url)

    FileUtils.mkdir_p tags_path
    Dir.chdir tags_path
    index_filename = File.join(tags_path, 'dynarextags.xml')

    if File.exists? index_filename then
      dynarex = Dynarex.new index_filename
    else
      dynarex = Dynarex.new('tags/tag(keyword,count)')
      dynarex.save index_filename, pretty: true
    end

    category_dynarex = Dynarex.new category_url

    a = category_dynarex.to_h.map {|item| item.values}
    category_dynarex = nil

    a.each do |title, url|

      a2 = title.scan(/#(\w+)/).flatten

      a2.each do |tag|

	      rec = dynarex.find_by_keyword tag
	      tagfile = tag + '.xml'

	      if rec then

	        rec.count = rec.count.succ
	        dyn = Dynarex.new(tagfile)
	        dyn.create(url: url, title: title)
	        dyn.save tagfile, pretty: true
	        dyn = nil

	      else

	        dynarex.create keyword: tag, count: '1'

	        dyn = Dynarex.new('items/item(title,url)')
	        dyn.create(url: url, title: title)
	        dyn.save tagfile, pretty: true
	        dyn = nil

	      end

      end
    end
    dynarex.save index_filename, pretty: true

  end
end
