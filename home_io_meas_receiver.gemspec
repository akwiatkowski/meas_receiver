# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "home_io_meas_receiver"
  s.version = "0.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Aleksander Kwiatkowski"]
  s.date = "2012-12-24"
  s.description = "Receive measurements from IoServer (part if HomeIO)."
  s.email = "bobikx@poczta.fm"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "lib/meas_receiver.rb",
    "lib/meas_receiver/comm_protocol.rb",
    "lib/meas_receiver/meas_type_buffer.rb",
    "lib/meas_receiver/meas_type_receiver.rb"
  ]
  s.homepage = "http://github.com/akwiatkowski/meas_receiver"
  s.licenses = ["LGPLv3"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.15"
  s.summary = "Measurements receiver"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rufus-scheduler>, [">= 0"])
      s.add_runtime_dependency(%q<mean>, [">= 0"])
      s.add_runtime_dependency(%q<colorize>, [">= 0"])
      s.add_development_dependency(%q<rspec>, ["~> 2.3.0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.6.4"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
    else
      s.add_dependency(%q<rufus-scheduler>, [">= 0"])
      s.add_dependency(%q<mean>, [">= 0"])
      s.add_dependency(%q<colorize>, [">= 0"])
      s.add_dependency(%q<rspec>, ["~> 2.3.0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.6.4"])
      s.add_dependency(%q<simplecov>, [">= 0"])
    end
  else
    s.add_dependency(%q<rufus-scheduler>, [">= 0"])
    s.add_dependency(%q<mean>, [">= 0"])
    s.add_dependency(%q<colorize>, [">= 0"])
    s.add_dependency(%q<rspec>, ["~> 2.3.0"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.6.4"])
    s.add_dependency(%q<simplecov>, [">= 0"])
  end
end

