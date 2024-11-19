# Setup script for GitHub development environment
# Installs and configures VS Code, VS Code Insiders, and GitHub tooling

# -----------------------------
# Constants and Variables
# -----------------------------

# Define VS Code theme
$VSCODE_THEME = "Default Dark+"

# Define common VS Code extensions
$vs_code_extensions = @(
    "GitHub.copilot",
    "GitHub.copilot-chat",
    "GitHub.codespaces",
    "github.vscode-github-actions",
    "github.copilot-workspace",
    "GitHub.vscode-pull-request-github",
    "GitHub.remotehub",
    "GitHub.vscode-codeql"
)

# Define GitHub CLI extensions
$gh_cli_extensions = @(
    "advanced-security/gh-sbom",
    "github/gh-actions-importer",
    "github/gh-classroom",
    "github/gh-codeql",
    "github/gh-copilot",
    "github/gh-gei",
    "github/gh-models"
)

# Define required sites
$PWA_SITES = @(
    "https://spark.githubnext.com",
    "https://copilot-workspace.githubnext.com"
)

$DEMO_SITES = @(
    "https://github.com"
) + $PWA_SITES

# -----------------------------
# Function Definitions
# -----------------------------

# Checks if Visual Studio Code is installed
function Check-VSCode {
    if (Test-Path "C:\Program Files\Microsoft VS Code\Code.exe") {
        Write-Output "VS Code is already installed"
        return $true
    } else {
        return $false
    }
}

# Checks if Visual Studio Code Insiders is installed
function Check-VSCodeInsiders {
    if (Test-Path "C:\Program Files\Microsoft VS Code Insiders\Code - Insiders.exe") {
        Write-Output "VS Code Insiders is already installed"
        return $true
    } else {
        return $false
    }
}

# Installs Chocolatey if not present
function Install-Chocolatey {
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Output "Installing Chocolatey..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    } else {
        Write-Output "Chocolatey is already installed"
    }
}

# Installs GitHub CLI using Chocolatey if not already installed
function Install-GitHubCLI {
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        Write-Output "Installing GitHub CLI..."
        choco install gh -y
    } else {
        Write-Output "GitHub CLI is already installed"
    }
}

# Installs a suite of GitHub CLI extensions
function Install-GitHubCLIExtensions {
    Write-Output "Installing GitHub CLI extensions..."
    foreach ($ext in $gh_cli_extensions) {
        gh extension install $ext
    }
}

# Installs VLC media player using Chocolatey
function Install-VLC {
    Write-Output "Installing VLC media player..."
    choco install vlc -y
}

# Installs Visual Studio Code using Chocolatey if not already present
function Install-VSCode {
    if (-not (Check-VSCode)) {
        Write-Output "Installing VS Code..."
        choco install vscode -y
    }
}

# Installs predefined VS Code extensions
function Install-VSCodeExtensions {
    Write-Output "Installing VS Code extensions..."
    foreach ($ext in $vs_code_extensions) {
        code --install-extension $ext
    }
}

# Installs Visual Studio Code Insiders using Chocolatey if not already present
function Install-VSCodeInsiders {
    if (-not (Check-VSCodeInsiders)) {
        Write-Output "Installing VS Code Insiders..."
        choco install vscode-insiders -y
    }
}

# Installs predefined VS Code extensions for VS Code Insiders
function Install-VSCodeInsidersExtensions {
    Write-Output "Installing VS Code Insiders extensions..."
    foreach ($ext in $vs_code_extensions) {
        code-insiders --install-extension $ext
    }
}

# Ensures user is authenticated with GitHub CLI and installs extensions if authenticated
function Setup-GitHubAuth {
    if (Get-Command gh -ErrorAction SilentlyContinue) {
        if (-not (gh auth status -h github.com -t)) {
            Write-Output "Please login to GitHub CLI first..."
            gh auth login
        }
        
        if (gh auth status -h github.com -t) {
            Install-GitHubCLIExtensions
        } else {
            Write-Output "GitHub CLI login required for installing extensions. Please run 'gh auth login' manually."
        }
    }
}

# Guides user through GitHub web authentication process using default browser
function Setup-GitHubWebAuth {
    Write-Output "Opening GitHub.com in default browser..."
    Start-Process "https://github.com"
    Read-Host "Please log in to GitHub.com in the browser with the demo account. Press Enter once you have logged in..."
    Write-Output "GitHub web authentication confirmed"
}

# Assists user in setting up Progressive Web Apps (PWAs) for GitHub tools
function Setup-SafariAndPWAs {
    Write-Output "Opening required websites in default browser..."
    foreach ($url in $PWA_SITES) {
        Start-Process $url
        Read-Host "Please manually add $url as a PWA. Press Enter when done..."
    }
}

# Sets the VS Code theme to the predefined value
function Set-VSCodeTheme {
    Write-Output "Setting VS Code theme..."
    $VSCODE_SETTINGS = "$env:APPDATA\Code\User\settings.json"
    
    if (-not (Test-Path $VSCODE_SETTINGS)) {
        New-Item -ItemType File -Path $VSCODE_SETTINGS -Force
    }
    
    $settings = Get-Content $VSCODE_SETTINGS -Raw | ConvertFrom-Json
    $settings."workbench.colorTheme" = $VSCODE_THEME
    $settings | ConvertTo-Json -Compress | Set-Content $VSCODE_SETTINGS
}

# Sets the VS Code Insiders theme to the predefined value
function Set-VSCodeInsidersTheme {
    Write-Output "Setting VS Code Insiders theme..."
    $VSCODE_SETTINGS = "$env:APPDATA\Code - Insiders\User\settings.json"
    
    if (-not (Test-Path $VSCODE_SETTINGS)) {
        New-Item -ItemType File -Path $VSCODE_SETTINGS -Force
    }
    
    $settings = Get-Content $VSCODE_SETTINGS -Raw | ConvertFrom-Json
    $settings."workbench.colorTheme" = $VSCODE_THEME
    $settings | ConvertTo-Json -Compress | Set-Content $VSCODE_SETTINGS
}

# Creates a demo loader script to launch all required applications and sites
function Create-DemoLoader {
    Write-Output "Creating demo loader script..."
    $DEMO_SCRIPT = "$env:USERPROFILE\Desktop\load-demos.ps1"
    
    $content = @"
# Open all required sites in default browser
"@ + ($DEMO_SITES | ForEach-Object { "Start-Process $_" }) -join "`n" + @"

# Open VS Code and VS Code Insiders
Start-Process "C:\Program Files\Microsoft VS Code\Code.exe"
Start-Process "C:\Program Files\Microsoft VS Code Insiders\Code - Insiders.exe"

# Open VLC pointing to Videos folder
Start-Process "C:\Program Files\VideoLAN\VLC\vlc.exe" "$env:USERPROFILE\Videos"
"@
    
    $content | Set-Content $DEMO_SCRIPT
    Set-ExecutionPolicy Bypass -Scope Process -Force
    Write-Output "Created demo loader script at $DEMO_SCRIPT"
}

# -----------------------------
# Main Execution
# -----------------------------

# Initial web authentication
Setup-GitHubWebAuth

# Install core tools
Install-Chocolatey
Install-VSCode
Install-VSCodeInsiders
Install-GitHubCLI
Install-VLC

# Setup environments
Setup-GitHubAuth
Setup-SafariAndPWAs

# Install extensions and configure themes
Install-VSCodeExtensions
Install-VSCodeInsidersExtensions
Set-VSCodeTheme
Set-VSCodeInsidersTheme

# Create demo loader script
Create-DemoLoader

# Verify installation
if (Check-VSCode -and Check-VSCodeInsiders -and (Get-Command vlc -ErrorAction SilentlyContinue) -and (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Output "Script completed successfully"
} else {
    Write-Output "There was an issue with the installation. Please check the error messages above."
}