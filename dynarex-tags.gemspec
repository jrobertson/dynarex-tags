Gem::Specification.new do |s|
  s.name = 'dynarex-tags'
  s.version = '0.1.8'
  s.summary = 'dynarex-tags'
  s.authors = ['James Robertson']
  s.files = Dir['lib/**/*.rb']
  s.add_dependency('dynarex') 
  s.signing_key = '../privatekeys/dynarex-tags.pem'
  s.cert_chain  = ['gem-public_cert.pem']
end
