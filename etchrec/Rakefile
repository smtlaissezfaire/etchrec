require 'rubygems'
Gem::manage_gems
require 'rake/gempackagetask'

spec = Gem::Specification.new do |s|
    s.name       = "etchrec"
    s.version    = "0.1.0"
    s.author     = "Scott Taylor"
    s.email      = "scott@railsnewbie.com"
    s.homepage   = "http://rubyforge.org/projects/etchrec"
    s.platform   = Gem::Platform::RUBY
    s.summary    = "Rails Deployment Recipes for GNU/Debian Etch"
    
    s.files      = FileList["lib/**/*"].to_a
    
    s.add_dependency 'deprec'
    s.add_dependency 'capistrano'
    
    s.has_rdoc          = false
    #s.extra_rdoc_files  = %w(README TODO DONE)
end

Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_tar = true
end