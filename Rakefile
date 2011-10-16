require 'rake/clean'

def coffee dst, src
    sh 'coffee', '-c', '-o', File.dirname(dst), src
end


file 'LiveReload.safariextension/global.js' => ['src/global.coffee'] do |task|
    coffee task.name, task.prerequisites.first
end

file 'LiveReload.safariextension/injected.js' => ['src/injected.coffee'] do |task|
    coffee task.name, task.prerequisites.first
end


desc "Build all files"
task :build => ['LiveReload.safariextension/global.js', 'LiveReload.safariextension/injected.js']

task :default => :build

CLOBBER.push *['LiveReload.safariextension/global.js', 'LiveReload.safariextension/injected.js']
