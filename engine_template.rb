# frozen_string_literal: true

# Usage: rails plugin new engines/your_engine --mountable --skip-git -m engine_template.rb

# Get the engine name and module name
def engine_name
  File.basename(destination_root)
end

def engine_module
  engine_name.camelize
end

# Helper to remove module wrappers from a file
def remove_module_wrapper(file_path, engine_module)
  return unless File.exist?(file_path)
  content = File.read(file_path)
  # Remove the outer module block
  content = content.gsub(/^module #{engine_module}\n(.*?)^end\n/m) { $1 }
  # Remove any indentation from the removed module
  content = content.gsub(/^  /, '')
  File.write(file_path, content)
end

# Move and de-namespace models, controllers, jobs
%w[models controllers jobs].each do |type|
  src = "app/#{type}/#{engine_name}"
  dest = "app/#{type}"
  if Dir.exist?(src)
    Dir.glob("{src}/**/*.rb").each do |file|
      filename = File.basename(file)
      new_path = File.join(dest, filename)
      FileUtils.mv(file, new_path)
      remove_module_wrapper(new_path, engine_module)
    end
    FileUtils.rm_rf(src)
  end
end

# De-namespace ApplicationRecord, ApplicationController, ApplicationJob
%w[application_record.rb application_controller.rb application_job.rb].each do |file|
  path = "app/#{file.split('_').first}/#{file}"
  remove_module_wrapper(path, engine_module)
end

# Optionally, update other files as needed (e.g., routes, initializers)
