# -*- encoding: utf-8 -*-
require File.expand_path("../lib/te2ak/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "te2ak"
  s.version     = TE2AK::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Zoltan Dezso']
  s.email       = ['dezso.zoltan@gmail.com']
  s.homepage    = "http://github.com/zaki/te2ak"
  s.summary     = "A simple utility to convert Textexpander snippets to AutoKey scripts."
  s.description = "A simple utility to convert Textexpander snippets to AutoKey scripts."

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "te2ak"

  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_dependency "plist", ">= 3.1.0"
  s.add_dependency "json", ">= 1.4.6"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
