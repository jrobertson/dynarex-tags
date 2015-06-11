Gem::Specification.new do |s|
  s.name = 'dynarex-tags'
  s.version = '0.2.0'
  s.summary = 'dynarex-tags'
  s.authors = ['James Robertson']
  s.files = Dir['lib/**/*.rb']
  s.add_runtime_dependency('dynarex', '~> 1.5', '>=1.5.23') 
  s.signing_key = '../privatekeys/dynarex-tags.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@r0bertson.co.uk'
  s.homepage = 'https://github.com/jrobertson/dynarex-tags'
  s.required_ruby_version = '>= 2.1.2'
end
