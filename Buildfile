require 'buildr/java'
require 'buildr/scala'

# Specify Maven 2.0 remote repositories here:
repositories.remote << 'http://mvn.bitcache.org/'
repositories.remote << 'http://scala-tools.org/repo-releases/'
repositories.remote << 'http://www.ibiblio.org/maven2/'

# Specify Maven 2.0 artifacts here:
SCALA = transitive('org.scala-lang:scala-library:jar:2.7.6')

# Specify the project's directory layout here:
LAYOUT = Layout.new
LAYOUT[:source, :main, :java]       = 'src/java'
LAYOUT[:source, :main, :scala]      = 'src/scala'
LAYOUT[:source, :spec, :scala]      = 'spec'
LAYOUT[:source, :spec, :resources]  = 'spec/resources'
LAYOUT[:reports, :specs]            = 'spec/reports'
LAYOUT[:target, :main]              = 'pkg/java'
LAYOUT[:target]                     = 'pkg/java'

desc   "Bitcache"
define "bitcache", :layout => LAYOUT do
  project.version = File.read('VERSION').chomp
  project.group   = 'org.bitcache'
  manifest['Implementation-Vendor'] = 'Bitcache.org'

  compile.options.target = '1.5'
  compile.with SCALA

  package :jar

  UPLOAD_LOCAL  = _('pkg/maven')
  UPLOAD_REMOTE = 'bitcache@mvn.bitcache.org:.m2/repository/'
  repositories.release_to = "file://#{UPLOAD_LOCAL}"
  task(:upload) do
    sh "rsync -avz --no-perms --chmod=ugo=rwX #{UPLOAD_LOCAL}/ #{UPLOAD_REMOTE}"
  end
end
