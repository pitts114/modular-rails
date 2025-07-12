
engine_dependencies = Set.new
circular_stack = []
external_deps = Hash.new { |h, k| h[k] = {} }
Dir.glob(File.expand_path("engines/*", __dir__)).each do |path|
  engine = File.basename(path)
  gemspec_file = File.join(path, "#{engine}.gemspec")
  next unless File.exist?(gemspec_file)
  scan_for_engine_dependencies(engine, engine_dependencies, circular_stack, external_deps)
end

engine_dependencies.each do |engine|
  gem engine, path: "engines/#{engine}", require: true
end

external_deps.each do |name, engine_reqs|
  engines = engine_reqs.keys
  uniq_reqs = engine_reqs.values.uniq
  if uniq_reqs.size > 1
    req_objs = uniq_reqs.map { |r| Gem::Requirement.new(r.split(/,\s*/)) }
    merged = req_objs.reduce(&:&)
    if merged.requirements.empty?
      raise "No version satisfies all requirements for #{name}: #{engine_reqs.inspect}"
    end
    version_req = merged.as_list.join(", ")
  else
    version_req = uniq_reqs.first
  end
  groups = engines.map(&:to_sym)
  group *groups do
    gem name, version_req
  end
end
