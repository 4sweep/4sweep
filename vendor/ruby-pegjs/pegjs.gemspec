Gem::Specification.new do |s|
  s.name    = 'pegjs'
  s.version = '0.0.1'
  s.date    = '2014-04-08'

  s.homepage = ''
  s.summary  = 'Ruby, peg.js compiler'
  s.description = <<-EOS
    Wrapper around the pegjs npm module that compiles PEG.js grammars and
    returns the corresponding JavaScript text.

    PEG.js is a parser generator for JavaScript with a simple syntax and good
    error reporting.

    Entirely derived from Dylon Edward's ruby-jison gem, see:
      https://github.com/dylon/ruby-jison
  EOS

  s.files = Dir.glob('lib/**/*.rb')

  s.authors = ['4sweep']
  s.email   = '4sweep@4sweep.com'
  s.license = 'MIT'
end
