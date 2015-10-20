require 'project/yaml'

def YAML.load_file file
  resource_dir = NSBundle.mainBundle.resourcePath
  path = File.join(resource_dir, file)
  YAML.load File.read(path)
end
