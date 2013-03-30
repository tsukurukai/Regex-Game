require 'rubygems'
require 'json'
require 'yaml'
 
DIR_ROOT = File.expand_path(File.dirname(__FILE__))
YAML_ROOT = DIR_ROOT 
JS_ROOT = DIR_ROOT 

# locale javascript namespace

Dir[File.join(YAML_ROOT, '*.yml')].sort.each { |locale| 
  locale_yml = YAML::load(IO.read(locale))
  File.open(
    File.join(JS_ROOT, File.basename(locale, '.*') + '.js'), 'w') {
      |f| f.write(locale_yml.to_json)
  }
}
