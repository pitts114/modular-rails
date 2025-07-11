# Usage:
#   bundle exec rake bogus_mine_qwen:process[CSV_PATH,MINER_ADDRESS]
#
# Example:
#   bundle exec rake bogus_mine_qwen:process[unsolved_qwen_tasks.csv,0x1234abcd...]
#
# This task processes each task_id from the given CSV file and calls Arbius::BogusMineService for the specified miner address.

namespace :bogus_mine_qwen do
  desc "Process each task_id from an input CSV file and call Arbius::BogusMineService"
  task :process, [ :csv_path, :miner_address ] => :environment do |t, args|
    require "csv"

    csv_path = args[:csv_path]
    miner_address = args[:miner_address]

    unless csv_path && File.exist?(csv_path)
      puts "Please provide a valid CSV file path."
      exit 1
    end

    unless miner_address
      puts "Please provide a miner_address."
      exit 1
    end

    miner = Arbius::Miner.find_by(address: miner_address)
    unless miner
      puts "Miner not found with address: #{miner_address}"
      exit 1
    end

    task_ids = []
    CSV.foreach(csv_path, headers: true) do |row|
      task_id = row["task_id"]
      if task_id
        task_ids << task_id
      else
        puts "No task_id found in row: #{row.inspect}"
      end
    end

    if task_ids.any?
      Arbius::BulkBogusMineJob.perform_later(miner.address, task_ids)
      puts "Processed #{task_ids.size} task_ids."
    else
      puts "No valid task_ids found in the CSV."
    end
  end
end
