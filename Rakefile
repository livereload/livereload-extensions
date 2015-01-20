VERSION_FILES = %w(
    src/common/version.coffee
    LiveReload.safariextension/Info.plist
    Chrome/LiveReload/manifest.json
    Firefox/install.rdf
)

def version
    content = File.read('package.json')
    if content =~ /"version": "(\d+\.\d+\.\d+)"/
        return $1
    else
        raise "Failed to get version info from package.json"
    end
end

def subst_version_refs_in_file file, ver
    puts file
    orig = File.read(file)
    prev_line = ""
    anything_matched = false
    data = orig.lines.map do |line|
        if line =~ /\d\.\d\.\d/ && (line =~ /version/i || prev_line =~ /CFBundleShortVersionString|CFBundleVersion/)
            anything_matched = true
            new_line = line.gsub /\d\.\d\.\d/, ver
            puts "    #{new_line.strip}"
        else
            new_line = line
        end
        prev_line = line
        new_line
    end.join('')

    raise "Error: no substitutions made in #{file}" unless anything_matched

    File.open(file, 'w') { |f| f.write data }
end

desc "Embed version number where it belongs"
task :version do
    ver = version
    VERSION_FILES.each { |file| subst_version_refs_in_file(file, ver) }
end


def upload_file file, folder='dist'
    path = "#{folder}/#{file}"
    # application/x-chrome-extension
    sh 's3cmd', '-P', '--mime-type=application/octet-stream', 'put', path, "s3://download.livereload.com/#{file}"
    puts "http://download.livereload.com/#{file}"
end

desc "Upload the chosen build to S3"
task 'upload:custom' do |t, args|
    require 'rubygems'
    require 'highline'
    HighLine.new.choose do |menu|
        menu.prompt = "Please choose a file to upload: "
        menu.choices(*Dir['dist/**/*.{crx,safariextz,xpi}'].sort.map { |f| f[5..-1] }) do |file|
            upload_file file
        end
    end
end

desc "Upload the latest Firefox build to S3"
task 'upload:firefox' do
    upload_file "#{version}/LiveReload-#{version}.xpi"
end

desc "Upload the latest Safari build to S3"
task 'upload:safari' do
    upload_file "#{version}/LiveReload-#{version}.safariextz"
end

desc "Upload the latest builds of all extensions to S3"
task 'upload:all' => ['upload:safari', 'upload:firefox']

desc "Upload update manifests"
task 'upload:manifest' do
    upload_file "LiveReload-Firefox-update.rdf",  'update'
    upload_file "LiveReload-Safari-update.plist", 'update'
end

desc "Tag the current version"
task :tag do
    sh 'git', 'tag', "v#{version}"
end
desc "Move (git tag -f) the tag for the current version"
task :retag do
    sh 'git', 'tag', '-f', "v#{version}"
end
