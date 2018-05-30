require 'asana'
require 'csv'
require 'json'
require 'logger'
require 'pp'
require 'pry'
require 'ruby-prof'
require 'yaml'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),'lib')) unless $LOAD_PATH.map { |l| File.expand_path(l) }.include? File.expand_path(File.join(File.dirname(__FILE__), 'lib'))

require 'vulnerability'
require 'vulnerability_list'

$logger = Logger.new(STDOUT)
$logger.level = Logger::DEBUG

$file_contents = open('secrets.yml', 'rb') do |io|
	io.read
end

$asana_access_token = YAML.load($file_contents)['ASANA_PAT']

$client = Asana::Client.new do |c|
	c.authentication :access_token, $asana_access_token
end

workspace = $client.workspaces.find_all.select do |workspace|
	workspace.name == 'stolaf.org'
end.first

project = $client.projects.find_all(workspace: workspace.id).select do |project|
	project.name == '[Sys] Security'
end.first

tag = $client.tags.find_all(workspace: workspace.id).select do |tag|
	tag.name == 'Automated [Nessus]'
end.first

pp project.sections

tasks = $client.tasks.find_by_tag(tag: tag.id).map do |flat_task|
	$logger.debug "Fetching task with id=#{flat_task.id}"
	$client.tasks.find_by_id(flat_task.id).to_h
end.select do |task_hash|
	!task_hash["completed"]
end

pp tasks

__END__

output = nil

result = RubyProf.profile do
	vulnerabilities = VulnerabilityList.from_csv(ARGV[0])

	$vulnerabilities = vulnerabilities.filter_risks.filter_not_accessible

	# vuln_plugin_mapping = $vulnerabilities.each_with_object({}) do |vuln, hash|
	# 	cve_string = vuln.cve ? " (#{vuln.cve})" : ""
	# 	puts "Adding entry for #{vuln.plugin_id}#{cve_string} on host #{vuln.host}:#{vuln.port} (#{vuln.protocol})"
	# 	hash[vuln.plugin_id] ||= []
	# 	hash[vuln.plugin_id].push vuln
	# end

	vulns_by_plugin = $vulnerabilities.each_with_object({}) do |vuln, hash|
		hash[vuln.plugin_id] ||= []
		hash[vuln.plugin_id] << vuln
	end

	reports = vulns_by_plugin.map do |plugin_id, vulns|
		uniqued_titles = vulns.map do |vuln|
			vuln.name
		end.uniq

		uniqued_cves = vulns.map do |vuln|
			vuln.cve
		end.uniq

		uniqued_cvsss = vulns.map do |vuln|
			vuln.cvss
		end.uniq

		uniqued_risks = vulns.map do |vuln|
			vuln.risk
		end.uniq

		throw "Plugin #{plugin_id} produced #{uniqued_titles.count} != 1 unique titles!" unless uniqued_titles.count == 1
		throw "Plugin #{plugin_id} produced #{uniqued_cvsss.count} != 1 unique CVSS's!" unless uniqued_cvsss.count == 1
		throw "Plugin #{plugin_id} produced #{uniqued_risks.count} != 1 unique risks!" unless uniqued_risks.count == 1

		uniqued_hosts = vulns.map do |vuln|
			vuln.readable_host
		end.uniq

		uniqued_synopses = vulns.map do |vuln|
			vuln.synopsis
		end.uniq

		throw "" unless uniqued_synopses.count == 1

		uniqued_descriptions = vulns.map do |vuln|
			vuln.description
		end.uniq

		throw "what" unless uniqued_descriptions.count == 1

		uniqued_solutions = vulns.map do |vuln|
			vuln.solution
		end.uniq

		throw "what" unless uniqued_solutions.count == 1

		{cvss: uniqued_cvsss.first, title: "[Nessus #{plugin_id}] #{uniqued_titles.join(', ')}", body: "CVE: #{uniqued_cves.first || 'N/A'}\nCVSS: #{uniqued_cvsss.first || 'N/A'}\nRisk: #{uniqued_risks.first || 'N/A'}\n\nSYNOPSIS\n\n#{uniqued_synopses.first}\n\nDESCRIPTION\n\n#{uniqued_descriptions.first.join("\n\n")}\n\nSOLUTION\n\n#{uniqued_solutions.first.join("\n\n")}\n\nThis issue was detected on #{uniqued_hosts.count} hosts: #{uniqued_hosts.join(', ')}", hosts: uniqued_hosts}
	end

	output = reports.sort do |report_a, report_b|
		report_b[:cvss] <=> report_a[:cvss]
	end.map do |report|
		[report[:title], report[:body]]
	end.to_a
end

printer = RubyProf::GraphPrinter.new(result)
printer.print(STDOUT, {})

CSV.open(ARGV[1], 'wb') do |csv|
	output.each do |row|
		csv << row
	end
end
