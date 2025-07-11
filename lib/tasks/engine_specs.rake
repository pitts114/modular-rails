# frozen_string_literal: true

desc "Run specs in all engines"
task :engine_specs do
  Dir.glob("engines/*").each do |engine_dir|
    spec_dir = File.join(engine_dir, "spec")
    next unless Dir.exist?(spec_dir)
    puts "\n== Running specs in #{engine_dir} =="
    Dir.chdir(engine_dir) do
      system("bundle exec rspec")
    end
  end
end
