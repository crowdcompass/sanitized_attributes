require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "sanitized_attributes"
    gem.summary = %Q{HTML-sanitizing attribute accessors for Ruby and Rails}
    gem.description = %Q{A wrapper to make automatic sanitization of incoming data easier. Uses the sanitize gem and works in both plain Ruby and Rails projects.}
    gem.email = "matthew.boeh@gmail.com"
    gem.homepage = "http://github.com/mboeh/sanitized_attributes"
    gem.authors = ["Matthew Boeh", "CrowdCompass, Inc."]
    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.add_dependency "sanitize", "> 0"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
  spec.rcov_opts = ['--exclude', File.expand_path("~/.rvm"), "--exclude", "spec"]
end

task :spec => :check_dependencies

task :default => :spec

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "sanitized_attributes #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
