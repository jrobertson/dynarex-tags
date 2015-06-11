# Introducing the Dynarex-tags gem

    require 'dynarex-tags'

    DynarexTags.new('/tmp').generate('http://www.jamesrobertson.eu/health/dynarex.xml')

This gem is designed primarily for parsing the title to fetch the hashtags from each Dynarex record entry to create a Dynarex tags file. It also create a tags directory containing a Dynarex file for each hashtag with a link to the original title and URL.

dynarextags tags
