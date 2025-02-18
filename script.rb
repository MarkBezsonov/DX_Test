require 'octokit'
require 'csv'
require 'time'

# GitHub API Token (Replace with your actual token or use ENV['GITHUB_TOKEN'])
ACCESS_TOKEN = ENV['GITHUB_TOKEN']
REPO = 'MarkBezsonov/DX_Test'  # Replace with your repo name

# Initialize GitHub client
client = Octokit::Client.new(access_token: ACCESS_TOKEN)

# Fetch pull requests (merged PRs only)
prs = client.pull_requests(REPO, state: 'closed').select { |pr| pr.merged_at }

# Generate file name with current date and time, replace slashes with underscores
file_name = "#{REPO.tr('/', '_')}_pull_requests_#{Time.now.strftime('%H-%M_%m-%d_%Y')}.csv"

CSV.open(file_name, 'w', write_headers: true, headers: [
  'PR Number', 'Author', 'Author GitHub Profile', 'Merged By', 'Merged By GitHub Profile',
  'Additions', 'Deletions', 'Created At', 'Merged At', 'Time to Merge (HH:MM:SS)'
]) do |csv|
  prs.each do |pr|
    # Fetch full PR details with changes (additions and deletions)
    full_pr = client.pull_request(REPO, pr.number)
    
    # Fetching additional details
    author = client.user(pr.user.login)
    
    # Fetch additional details, including the merged_by field
    merged_by = pr.merged_by ? client.user(pr.merged_by.login) : author

    # Use merged_by login and profile only if available
    merged_by_login = merged_by ? merged_by.login : "N/A"
    merged_by_profile = merged_by ? merged_by.html_url : "N/A"
    
    # Calculate time to merge in HH:MM:SS format
    time_to_merge_seconds = pr.merged_at ? (Time.parse(pr.merged_at.to_s) - Time.parse(pr.created_at.to_s)) : 0
    time_to_merge = Time.at(time_to_merge_seconds).utc.strftime("%H:%M:%S")

    # Write to CSV
    csv << [
      pr.number, 
      author.login, author.html_url,
      merged_by_login, merged_by_profile,
      full_pr.additions, full_pr.deletions, 
      pr.created_at, pr.merged_at || "N/A", 
      time_to_merge
    ]
  end
end

puts "CSV file generated: #{file_name}"