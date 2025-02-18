Footnotes:

The report has the following column headers:

* PR Number
* Author
* Author GitHub Profile
* Merged By
* Merged By GitHub Profile
* Additions
* Deletions
* Created At
* Merged At
* Time to Merge (HH:MM:SS)

The report's name is configured to be the following on line 16 in script.rb - feel free to change this to your preferences:

file_name = "#{REPO.tr('/', '_')}_pull_requests_#{Time.now.strftime('%H-%M_%m-%d_%Y')}.csv"

For the following snippet on line 6 in script.rb:

ACCESS_TOKEN = ENV['GITHUB_TOKEN']

You need to create a token via https://github.com/settings/personal-access-tokens and then set it locally via the following options:

----
Windows: Powershell (as administrator):

$env:GITHUB_TOKEN="insert_token_here"

----
MacOS/Linux: Terminal (as administrator):

export GITHUB_TOKEN="your_personal_access_token"
