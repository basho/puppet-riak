# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'rubygems'
require "bundler"
Bundler.setup(:default)
require 'rake'
require 'rspec/core/rake_task'
require 'rspec-puppet'
require 'yaml'

task :default => [:help]

desc "Run spec tests on an existing fixtures directory"
RSpec::Core::RakeTask.new(:spec_standalone) do |t|
  t.rspec_opts = ['--color']
  t.pattern = 'spec/{classes,defines,unit,functions,hosts}/**/*_spec.rb'
end

desc "Generate code coverage information"
RSpec::Core::RakeTask.new(:coverage) do |t|
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec']
end

# This is a helper for the self-symlink entry of fixtures.yml
def source_dir
  Dir.pwd
end

def fixtures(category)
  begin
    fixtures = YAML.load_file(".fixtures.yml")["fixtures"]
  rescue Errno::ENOENT
    return {}
  end

  if not fixtures
    abort("malformed fixtures.yml")
  end

  result = {}
  if fixtures.include? category
    fixtures[category].each do |fixture, source|
      target = "spec/fixtures/modules/#{fixture}"
      real_source = eval('"'+source+'"')
      result[real_source] = target
    end
  end
  return result
end

# Create the fixtures directory
task :spec_prep do
  fixtures("repositories").each do |repo, target|
    File::exists?(target) || system("git clone #{repo} #{target}")
  end

  FileUtils::mkdir_p("spec/fixtures/modules")
  fixtures("symlinks").each do |source, target|
    File::exists?(target) || FileUtils::ln_s(source, target)
  end

  FileUtils::mkdir_p("tests/data") unless File.exists? "tests/data"
  FileUtils::mkdir_p("spec/fixtures/manifests")
  file = 'spec/fixtures/manifests/vagrant-riak.pp'
  File.open(file, 'w+') { |f| f.puts 'node default { include riak }' } unless File.exists? file
  cp file, File.join(File.dirname(file), 'site.pp')
end

desc "Clean up the fixtures directory"
task :spec_clean do
  fixtures("repositories").each do |repo, target|
    FileUtils::rm_rf(target)
  end

  fixtures("symlinks").each do |source, target|
    FileUtils::rm(target)
  end

  FileUtils::rm("spec/fixtures/manifests/vagrant-riak.pp")
end

desc "Check puppet manifests with puppet-lint"
task :lint do
  require 'puppet-lint/tasks/puppet-lint'
  PuppetLint.configuration.send("disable_80chars")
end

desc "Display the list of available rake tasks"
task :help do
  system("rake -T")
end

desc 'like \'rake spec\' but without deleting fixture contents'
task :specs do
  Rake::Task[:spec_prep].invoke
  Rake::Task[:spec_standalone].invoke
end

#desc 'runs \'puppet apply --noop\' on the manifests'
#task :noop do
#  system 'find tests -name init.pp | xargs -n 1 -t bundle exec puppet apply --noop --modulepath=spec/fixtures/modules'
#end

directory 'graphs'

desc "Convert too dotfiles in the graph folder to png files"
task :dot_to_png => 'graphs' do
  Dir.glob('graphs/*.dot') do |dot|
    puts "Converting #{dot} to png"
    which = RUBY_PLATFORM =~ /(win|w)32$/ ? "where dot >NUL 2>&1" : "which dot >/dev/null 2>&1"
    system "dot -Tpng #{dot} -o graphs/#{File.basename(dot, '.*')}.png" if system(which)
  end
end

namespace :vagrant do

  desc 'Bring the VM up'
  task :up => [:spec_prep] do
    system 'vagrant up'
  end

  desc 'Suspend the VM (alias \'suspend\')'
  task :down => [:spec_prep] do
    system 'vagrant suspend'
  end

  task :suspend => :down

  task :_provision do ; system 'vagrant provision' ; end

  desc 'Provision VM when already running'
  task :provision => [:spec_prep, :"vagrant:_provision", :dot_to_png]

  desc 'Destroy the VM completely'
  task :destroy do
    system 'vagrant destroy'
  end

  desc 'Get the status'
  task :status do
    system 'vagrant status'
  end

  task :reload => [:spec_prep] do
    system 'vagrant reload'
  end
end

namespace :module do

  directory 'pkg/riak'

  desc "Build puppet module package"
  task :build => 'pkg/riak' do
    `git ls-files`.split("\n").
      reject { |f| f =~ /^(\.|Guardfile|Gemfile|Rakefile|Vagrantfile|spec\/|tests\/)/ }.
      each  do |f|
        if f =~ /\//
          FileUtils.mkdir_p(File.join('pkg', 'riak', File.dirname(f)))
        end
        cp f, File.join('pkg', 'riak', f)
      end
    system 'puppet module build pkg/riak'
    Dir.glob('pkg/riak/pkg/*.tar.gz').each { |f| cp f, 'pkg' }
  end

  task :build_ do
    # This will be deprecated once puppet-module is a face.
    begin
      Gem::Specification.find_by_name('puppet-module')
    rescue Gem::LoadError, NoMethodError
      require 'puppet/face'
      pmod = Puppet::Face['module', :current]
      pmod.build('./')
    end
  end

  desc "Clean a built module package"
  task :clean do
    FileUtils.rm_rf("pkg")
  end

end
