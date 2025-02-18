require 'octokit'
require 'csv'
require 'time'
require 'byebug'

# GitHub API Token (Replace with your actual token or use ENV['GITHUB_TOKEN'])
ACCESS_TOKEN = ENV['GITHUB_TOKEN']
REPO = 'MarkBezsonov/DX_Test'  # Example: 'rails/rails'

# Initialize GitHub client
client = Octokit::Client.new(access_token: ACCESS_TOKEN)

# Fetch pull requests (merged PRs only)
prs = client.pull_requests(REPO, state: 'closed').select { |pr| pr.merged_at }

# Generate timestamp for the output file
timestamp = Time.now.strftime("%H-%M %m_%d_%Y")  # Changed colon to dash

# Replace '/' with '_' in the repo name to avoid issues with file paths
safe_repo_name = REPO.tr('/', '_')

# Use the safe repository name in the output file
file_name = "#{safe_repo_name}_pull_requests_#{timestamp}.csv"

CSV.open(file_name, 'w', write_headers: true, headers: [
  'PR Number', 'Author', 'Author GitHub Profile', 'Merged By', 'Merged By GitHub Profile',
  'Additions', 'Deletions', 'Created At', 'Merged At', 'Time to Merge (HH:MM:SS)'
]) do |csv|
  prs.each do |pr|
    author = client.user(pr.user.login)
    merged_by = pr.merged_by ? client.user(pr.merged_by.login) : author  # Use author if merged_by is nil
    time_to_merge = if pr.merged_at && pr.created_at
                     time_diff = Time.parse(pr.merged_at.to_s) - Time.parse(pr.created_at.to_s)
                     hours = (time_diff / 3600).to_i
                     minutes = ((time_diff % 3600) / 60).to_i
                     seconds = (time_diff % 60).to_i
                     format("%02d:%02d:%02d", hours, minutes, seconds)
                   else
                     "N/A"
                   end

    # Handle missing additions or deletions by setting them to 0 if nil
    additions = pr.additions || 0
    deletions = pr.deletions || 0

    csv << [
      pr.number, 
      author.login, author.html_url,
      merged_by.login, merged_by.html_url,
      additions, deletions, 
      pr.created_at, pr.merged_at || "N/A", 
      time_to_merge
    ]
  end
end

puts "CSV file generated: #{file_name}"