require 'rake/clean'

def coffee dst, src
    sh 'coffee', '-c', '-b', '-o', File.dirname(dst), src
end

def concat dst, *srcs
    text = srcs.map { |src| File.read(src).rstrip + "\n" }
    File.open(dst, 'w') { |f| f.write text }
end


file 'LiveReload.safariextension/global.js' => ['src/global.coffee'] do |task|
    coffee task.name, task.prerequisites.first
end

file 'LiveReload.safariextension/global-safari.js' => ['src/global-safari.coffee'] do |task|
    coffee task.name, task.prerequisites.first
end

file 'interim/injected.js' => ['src/injected.coffee'] do |task|
    coffee task.name, task.prerequisites.first
end

file 'interim/injected-safari.js' => ['src/injected-safari.coffee'] do |task|
    coffee task.name, task.prerequisites.first
end

file 'LiveReload.safariextension/injected.js' => ['interim/injected.js', 'interim/injected-safari.js'] do |task|
    concat task.name, *task.prerequisites
end


desc "Build all files"
task :build => ['LiveReload.safariextension/global.js', 'LiveReload.safariextension/injected.js']

desc "Upload the given build to S3"
task :upload do |t, args|
    require 'rubygems'
    require 'highline'
    HighLine.new.choose do |menu|
        menu.prompt = "Please choose a file to upload: "
        menu.choices(*Dir['dist/*.{crx,safariextz}'].map { |f| File.basename(f) }) do |file|
            path = "dist/#{file}"
            sh 's3cmd', '-P', 'put', path, "s3://download.livereload.com/#{file}"
            puts "http://download.livereload.com/#{file}"
        end
    end
end

task :default => :build

CLEAN.push *['interim/injected.js', 'interim/injected-safari.js']
CLOBBER.push *['LiveReload.safariextension/global.js', 'LiveReload.safariextension/injected.js']
