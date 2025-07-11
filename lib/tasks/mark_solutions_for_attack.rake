# Usage:
#   bundle exec rake arbius:mark_solutions_for_attack[COUNT,CSV_FILE]
#
# Example:
#   bundle exec rake arbius:mark_solutions_for_attack[5,addresses.csv]
#
# Note:
#   - The CSV file should have one address per row in the first column (header or no header).
#
require "csv"

namespace :arbius do
  desc "Mark solutions for attack for a list of addresses from a CSV file"
  task :mark_solutions_for_attack, [ :count, :csv_file ] => :environment do |t, args|
    count = args[:count].to_i
    addresses = []
    csv_path = args[:csv_file].to_s.strip
    raise ArgumentError, "CSV file not found: #{csv_path}" unless File.exist?(csv_path)
    CSV.foreach(csv_path, headers: true) do |row|
      addresses << row[0].to_s.strip if row[0].present?
    end
    addresses.reject!(&:empty?)
    raise ArgumentError, "count must be > 0" if count <= 0
    raise ArgumentError, "addresses must be provided" if addresses.empty?

    service = Arbius::MarkSolutionsForAttackBatchService.new
    service.call(count: count, addresses: addresses)
  end
end
