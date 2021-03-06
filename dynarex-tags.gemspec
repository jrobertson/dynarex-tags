Gem::Specification.new do |s|
  s.name = 'dynarex-tags'
  s.version = '0.5.0'
  s.summary = 'Uses hashtags to help reference 1 or more ' + 
      'records from an index file.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/dynarex-tags.rb']
  s.add_runtime_dependency('dynarex', '~> 1.8', '>=1.8.23') 
  s.signing_key = '../privatekeys/dynarex-tags.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@jamesrobertson.eu'
  s.homepage = 'https://github.com/jrobertson/dynarex-tags'
  s.required_ruby_version = '>= 2.1.2'
end
