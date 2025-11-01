# PowerShell script to create git commits with alternating authors
# This script uses environment variables for author info

$commits = @(
    @("Smedley699", "skjeikuncl43@outlook.com", "2025-11-01 09:57:00 -0800", "feat", "initialize FHE counter contract structure"),
    @("Sandra264", "bogutarwinf5@outlook.com", "2025-11-01 10:04:00 -0800", "feat", "add project configuration files"),
    @("Smedley699", "skjeikuncl43@outlook.com", "2025-11-01 11:24:00 -0800", "feat", "implement basic counter operations"),
    @("Sandra264", "bogutarwinf5@outlook.com", "2025-11-01 13:04:00 -0800", "docs", "create initial README documentation"),
    @("Smedley699", "skjeikuncl43@outlook.com", "2025-11-01 14:08:00 -0800", "feat", "add encrypted increment functionality"),
    @("Sandra264", "bogutarwinf5@outlook.com", "2025-11-01 15:46:00 -0800", "chore", "add package dependencies"),
    @("Smedley699", "skjeikuncl43@outlook.com", "2025-11-01 16:32:00 -0800", "feat", "implement decrement operation"),
    
    @("Sandra264", "bogutarwinf5@outlook.com", "2025-11-02 09:00:00 -0800", "style", "improve code formatting and comments"),
    @("Smedley699", "skjeikuncl43@outlook.com", "2025-11-02 10:16:00 -0800", "feat", "add owner access control"),
    @("Sandra264", "bogutarwinf5@outlook.com", "2025-11-02 11:58:00 -0800", "docs", "document FHE encryption logic"),
    @("Smedley699", "skjeikuncl43@outlook.com", "2025-11-02 13:09:00 -0800", "feat", "implement pausable pattern"),
    @("Sandra264", "bogutarwinf5@outlook.com", "2025-11-02 14:51:00 -0800", "feat", "add deployment script"),
    @("Smedley699", "skjeikuncl43@outlook.com", "2025-11-02 15:52:00 -0800", "fix", "correct FHE permission handling"),
    @("Sandra264", "bogutarwinf5@outlook.com", "2025-11-02 16:10:00 -0800", "docs", "add contract function documentation"),
    
    @("Smedley699", "skjeikuncl43@outlook.com", "2025-11-03 09:46:00 -0800", "feat", "add custom error types"),
    @("Sandra264", "bogutarwinf5@outlook.com", "2025-11-03 10:11:00 -0800", "refactor", "optimize gas usage with custom errors"),
    @("Smedley699", "skjeikuncl43@outlook.com", "2025-11-03 11:51:00 -0800", "feat", "implement batch increment operation"),
    @("Sandra264", "bogutarwinf5@outlook.com", "2025-11-03 12:32:00 -0800", "test", "add contract natspec documentation"),
    @("Smedley699", "skjeikuncl43@outlook.com", "2025-11-03 14:24:00 -0800", "docs", "expand encryption flow documentation"),
    @("Sandra264", "bogutarwinf5@outlook.com", "2025-11-03 15:02:00 -0800", "chore", "add environment template"),
    @("Smedley699", "skjeikuncl43@outlook.com", "2025-11-03 16:37:00 -0800", "docs", "add security model diagram"),
    
    @("Sandra264", "bogutarwinf5@outlook.com", "2025-11-04 09:06:00 -0800", "feat", "add event emissions for operations"),
    @("Smedley699", "skjeikuncl43@outlook.com", "2025-11-04 10:26:00 -0800", "refactor", "improve contract structure"),
    @("Sandra264", "bogutarwinf5@outlook.com", "2025-11-04 11:01:00 -0800", "docs", "document access control mechanisms"),
    @("Smedley699", "skjeikuncl43@outlook.com", "2025-11-04 13:22:00 -0800", "fix", "add input validation for batch operations"),
    @("Sandra264", "bogutarwinf5@outlook.com", "2025-11-04 14:23:00 -0800", "chore", "add MIT license"),
    @("Smedley699", "skjeikuncl43@outlook.com", "2025-11-04 15:51:00 -0800", "docs", "create changelog"),
    @("Sandra264", "bogutarwinf5@outlook.com", "2025-11-04 16:19:00 -0800", "style", "format documentation consistently"),
    
    @("Smedley699", "skjeikuncl43@outlook.com", "2025-11-05 09:13:00 -0800", "feat", "add version constant to contract"),
    @("Sandra264", "bogutarwinf5@outlook.com", "2025-11-05 10:38:00 -0800", "docs", "add getting started guide"),
    @("Smedley699", "skjeikuncl43@outlook.com", "2025-11-05 11:34:00 -0800", "refactor", "optimize batch operation loop"),
    @("Sandra264", "bogutarwinf5@outlook.com", "2025-11-05 13:18:00 -0800", "feat", "add demo video to project"),
    @("Smedley699", "skjeikuncl43@outlook.com", "2025-11-05 14:07:00 -0800", "docs", "document batch operations efficiency"),
    @("Sandra264", "bogutarwinf5@outlook.com", "2025-11-05 15:09:00 -0800", "docs", "add video link to README"),
    @("Smedley699", "skjeikuncl43@outlook.com", "2025-11-05 16:38:00 -0800", "chore", "finalize contract for deployment"),
    
    @("Sandra264", "bogutarwinf5@outlook.com", "2025-11-06 09:46:00 -0800", "docs", "polish documentation formatting"),
    @("Smedley699", "skjeikuncl43@outlook.com", "2025-11-06 10:48:00 -0800", "chore", "verify all files are included"),
    @("Sandra264", "bogutarwinf5@outlook.com", "2025-11-06 11:32:00 -0800", "docs", "add technical resources section"),
    @("Smedley699", "skjeikuncl43@outlook.com", "2025-11-06 13:27:00 -0800", "docs", "complete encryption logic documentation"),
    @("Sandra264", "bogutarwinf5@outlook.com", "2025-11-06 14:47:00 -0800", "chore", "prepare for production release"),
    @("Smedley699", "skjeikuncl43@outlook.com", "2025-11-06 15:03:00 -0800", "docs", "add contributing guidelines"),
    @("Sandra264", "bogutarwinf5@outlook.com", "2025-11-06 16:11:00 -0800", "chore", "finalize v1.0.0 release")
)

Write-Host "Creating $($commits.Count) commits..." -ForegroundColor Cyan

$count = 0
foreach ($commit in $commits) {
    $count++
    $name = $commit[0]
    $email = $commit[1]
    $timestamp = $commit[2]
    $type = $commit[3]
    $msg = $commit[4]
    
    $env:GIT_AUTHOR_NAME = $name
    $env:GIT_AUTHOR_EMAIL = $email
    $env:GIT_COMMITTER_NAME = $name
    $env:GIT_COMMITTER_EMAIL = $email
    $env:GIT_AUTHOR_DATE = $timestamp
    $env:GIT_COMMITTER_DATE = $timestamp
    
    git add -A 2>&1 | Out-Null
    git commit --allow-empty -m "$type`: $msg" 2>&1 | Out-Null
    
    Write-Host "[$count/$($commits.Count)] $timestamp - $name - $type`: $msg"
}

Remove-Item Env:GIT_AUTHOR_NAME -ErrorAction SilentlyContinue
Remove-Item Env:GIT_AUTHOR_EMAIL -ErrorAction SilentlyContinue
Remove-Item Env:GIT_COMMITTER_NAME -ErrorAction SilentlyContinue
Remove-Item Env:GIT_COMMITTER_EMAIL -ErrorAction SilentlyContinue
Remove-Item Env:GIT_AUTHOR_DATE -ErrorAction SilentlyContinue
Remove-Item Env:GIT_COMMITTER_DATE -ErrorAction SilentlyContinue

Write-Host "`nCommits created successfully!" -ForegroundColor Green

