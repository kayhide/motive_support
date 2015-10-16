MotionBlender.raketime do
  require 'motion-yaml'
end

MotionBlender.runtime do
  require 'project/yaml'

  def YAML.load_file file
    resource_dir = NSBundle.mainBundle.resourcePath
    path = File.join(resource_dir, file)
    YAML.load File.read(path)
  end
end
