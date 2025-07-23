
## **📁 scripts/install-iis.ps1**

```powershell
<#
.SYNOPSIS
    Automated IIS Installation and Configuration Script for Azure Load Balancer Project

.DESCRIPTION
    This PowerShell script automates the installation of Internet Information Services (IIS)
    on Windows Server 2022 virtual machines and creates custom test pages for load balancer
    verification in an Azure environment.

.NOTES
    Author: Azure Load Balancer Project
    Version: 1.0
    Requires: Windows Server 2022, Administrator privileges
    Usage: Run this script on each VM (lb-vm1 and lb-vm2) after deployment
#>

# Enable strict mode for better error handling
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Define script variables
$LogPath = "C:\Temp\IIS-Installation.log"
$WebRootPath = "C:\inetpub\wwwroot"
$BackupPath = "C:\Temp\WebBackup"

# Create logging directory if it doesn't exist
if (!(Test-Path -Path "C:\Temp")) {
    New-Item -ItemType Directory -Path "C:\Temp" -Force | Out-Null
}

# Function to write log entries
function Write-LogEntry {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        [Parameter(Mandatory=$false)]
        [string]$Level = "INFO"
    )
    
    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$TimeStamp] [$Level] $Message"
    Write-Host $LogEntry
    Add-Content -Path $LogPath -Value $LogEntry
}

# Function to check if script is running as administrator
function Test-AdminPrivileges {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Function to get server name for custom content
function Get-ServerIdentifier {
    $computerName = $env:COMPUTERNAME
    if ($computerName -like "*vm1*" -or $computerName -like "*VM1*") {
        return @{
            ServerName = "lb-vm1"
            ServerNumber = "1"
            Color = "#e3f2fd"
            AccentColor = "#1976d2"
            Icon = "🚀"
        }
    } elseif ($computerName -like "*vm2*" -or $computerName -like "*VM2*") {
        return @{
            ServerName = "lb-vm2" 
            ServerNumber = "2"
            Color = "#e8f5e8"
            AccentColor = "#388e3c"
            Icon = "🌟"
        }
    } else {
        return @{
            ServerName = $computerName
            ServerNumber = "Unknown"
            Color = "#f3e5f5"
            AccentColor = "#7b1fa2"
            Icon = "💻"
        }
    }
}

# Main installation function
function Install-IISWebServer {
    try {
        Write-LogEntry "Starting IIS installation process"
        
        # Check for administrator privileges
        if (!(Test-AdminPrivileges)) {
            throw "This script must be run as Administrator"
        }

        # Get Windows version
        $osVersion = (Get-WmiObject -Class Win32_OperatingSystem).Caption
        Write-LogEntry "Operating System: $osVersion"

        # Install IIS Web Server role
        Write-LogEntry "Installing IIS Web Server role..."
        $installResult = Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole -All
        
        if ($installResult.RestartNeeded) {
            Write-LogEntry "WARNING: Restart required after IIS installation" "WARN"
        }

        # Install additional IIS features
        Write-LogEntry "Installing additional IIS features..."
        $features = @(
            "IIS-WebServer",
            "IIS-CommonHttpFeatures", 
            "IIS-HttpErrors",
            "IIS-HttpRedirect",
            "IIS-ApplicationDevelopment",
            "IIS-NetFxExtensibility45",
            "IIS-HealthAndDiagnostics",
            "IIS-HttpLogging",
            "IIS-Security",
            "IIS-RequestFiltering",
            "IIS-Performance",
            "IIS-WebServerManagementTools",
            "IIS-ManagementConsole",
            "IIS-IIS6ManagementCompatibility",
            "IIS-Metabase"
        )

        foreach ($feature in $features) {
            try {
                Enable-WindowsOptionalFeature -Online -FeatureName $feature -All | Out-Null
                Write-LogEntry "Installed feature: $feature"
            } catch {
                Write-LogEntry "Failed to install feature: $feature - $($_.Exception.Message)" "WARN"
            }
        }

        # Verify IIS installation
        $iisService = Get-Service -Name W3SVC -ErrorAction SilentlyContinue
        if ($iisService -and $iisService.Status -eq "Running") {
            Write-LogEntry "IIS Web Server installed and running successfully"
        } else {
            Write-LogEntry "Starting IIS Web Server service..."
            Start-Service -Name W3SVC
            Set-Service -Name W3SVC -StartupType Automatic
        }

        return $true
    }
    catch {
        Write-LogEntry "Error during IIS installation: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

# Function to create custom test page
function New-CustomTestPage {
    try {
        Write-LogEntry "Creating custom test page..."
        
        # Get server-specific information
        $serverInfo = Get-ServerIdentifier
        $serverName = $serverInfo.ServerName
        $serverNumber = $serverInfo.ServerNumber
        $bgColor = $serverInfo.Color
        $accentColor = $serverInfo.AccentColor
        $icon = $serverInfo.Icon

        # Create backup of existing files
        if (Test-Path -Path "$WebRootPath\iisstart.htm") {
            if (!(Test-Path -Path $BackupPath)) {
                New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null
            }
            Copy-Item -Path "$WebRootPath\*" -Destination $BackupPath -Recurse -Force
            Write-LogEntry "Backed up existing web files to $BackupPath"
        }

        # Generate dynamic content
        $currentTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $ipAddress = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.PrefixOrigin -eq "Dhcp" }).IPAddress
        $machineName = $env:COMPUTERNAME
        
        # Create HTML content
        $htmlContent = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Azure Load Balancer Test - Server $serverNumber</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body { 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, $bgColor 0%, #ffffff 100%);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        
        .container {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            padding: 40px;
            max-width: 600px;
            width: 100%;
            text-align: center;
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
        
        h1 { 
            color: $accentColor;
            font-size: 2.5em;
            margin-bottom: 20px;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.1);
        }
        
        .server-info {
            background: linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%);
            border-radius: 15px;
            padding: 30px;
            margin: 20px 0;
            border-left: 5px solid $accentColor;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.08);
        }
        
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin: 20px 0;
        }
        
        .info-item {
            background: rgba($accentColor, 0.05);
            padding: 15px;
            border-radius: 10px;
            border: 1px solid rgba($accentColor, 0.1);
        }
        
        .info-label {
            font-weight: bold;
            color: $accentColor;
            font-size: 0.9em;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 5px;
        }
        
        .info-value {
            font-size: 1.1em;
            color: #333;
        }
        
        .status-badge {
            display: inline-block;
            background: #28a745;
            color: white;
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 0.9em;
            font-weight: bold;
            margin: 10px 0;
        }
        
        .timestamp {
            background: rgba(0, 0, 0, 0.05);
            padding: 10px;
            border-radius: 8px;
            font-family: 'Courier New', monospace;
            margin: 15px 0;
        }
        
        .footer {
            margin-top: 20px;
            padding: 20px 0;
            border-top: 2px solid rgba($accentColor, 0.1);
            color: #666;
            font-size: 0.9em;
        }
        
        .load-balancer-info {
            background: linear-gradient(135deg, rgba($accentColor, 0.1) 0%, rgba($accentColor, 0.05) 100%);
            border-radius: 10px;
            padding: 20px;
            margin: 20px 0;
        }
        
        @keyframes pulse {
            0% { transform: scale(1); }
            50% { transform: scale(1.05); }
            100% { transform: scale(1); }
        }
        
        .pulse {
            animation: pulse 2s infinite;
        }
        
        .health-indicator {
            display: inline-block;
            width: 12px;
            height: 12px;
            background: #28a745;
            border-radius: 50%;
            margin-right: 8px;
            animation: pulse 2s infinite;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>$icon Hello from $serverName!</h1>
        
        <div class="server-info">
            <h2>Azure Load Balancer Test Page</h2>
            <div class="status-badge">
                <span class="health-indicator"></span>Web Server Online
            </div>
            
            <div class="info-grid">
                <div class="info-item">
                    <div class="info-label">Server Name</div>
                    <div class="info-value">$serverName</div>
                </div>
                <div class="info-item">
                    <div class="info-label">Machine Name</div>
                    <div class="info-value">$machineName</div>
                </div>
                <div class="info-item">
                    <div class="info-label">Private IP</div>
                    <div class="info-value">$ipAddress</div>
                </div>
                <div class="info-item">
                    <div class="info-label">Availability Zone</div>
                    <div class="info-value">Zone 1</div>
                </div>
            </div>
            
            <div class="timestamp">
                <strong>Page Generated:</strong> $currentTime<br>
                <strong>Current Time:</strong> <span id="current-time"></span>
            </div>
        </div>
        
        <div class="load-balancer-info">
            <h3>🔄 Load Balancer Status</h3>
            <p>This page is served by <strong>Server $serverNumber</strong> in your Azure Load Balancer backend pool.</p>
            <p>Refresh the page multiple times to see traffic distribution between servers.</p>
        </div>
        
        <div class="footer">
            <p>🏗️ <strong>Azure Load Balancer Project</strong></p>
            <p>High-Availability Web Infrastructure for E-commerce Platform</p>
            <p>Powered by Windows Server 2022 & IIS 10.0</p>
        </div>
    </div>
    
    <script>
        // Update current time every second
        function updateTime() {
            const now = new Date();
            document.getElementById('current-time').textContent = now.toLocaleString();
        }
        
        updateTime();
        setInterval(updateTime, 1000);
        
        // Add some interactivity
        document.addEventListener('DOMContentLoaded', function() {
            const container = document.querySelector('.container');
            container.addEventListener('mouseenter', function() {
                this.style.transform = 'scale(1.02)';
                this.style.transition = 'transform 0.3s ease';
            });
            
            container.addEventListener('mouseleave', function() {
                this.style.transform = 'scale(1)';
            });
        });
        
        // Performance monitoring
        window.addEventListener('load', function() {
            const loadTime = window.performance.timing.loadEventEnd - window.performance.timing.navigationStart;
            console.log('Page load time:', loadTime + 'ms');
        });
    </script>
</body>
</html>
"@

        # Write HTML content to file
        $htmlContent | Out-File -FilePath "$WebRootPath\index.html" -Encoding UTF8 -Force
        
        # Also create iisstart.htm for compatibility
        $htmlContent | Out-File -FilePath "$WebRootPath\iisstart.htm" -Encoding UTF8 -Force
        
        Write-LogEntry "Custom test page created successfully for $serverName"
        
        # Set appropriate permissions
        $acl = Get-Acl $WebRootPath
        $acl.SetAccessRuleProtection($false, $true)
        Set-Acl -Path $WebRootPath -AclObject $acl
        
        return $true
    }
    catch {
        Write-LogEntry "Error creating custom test page: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

# Function to configure Windows Firewall
function Set-FirewallRules {
    try {
        Write-LogEntry "Configuring Windows Firewall rules..."
        
        # Enable HTTP traffic
        New-NetFirewallRule -DisplayName "Allow HTTP" -Direction Inbound -Protocol TCP -LocalPort 80 -Action Allow -ErrorAction SilentlyContinue
        Write-LogEntry "HTTP firewall rule configured"
        
        # Enable HTTPS traffic
        New-NetFirewallRule -DisplayName "Allow HTTPS" -Direction Inbound -Protocol TCP -LocalPort 443 -Action Allow -ErrorAction SilentlyContinue
        Write-LogEntry "HTTPS firewall rule configured"
        
        # Ensure RDP is allowed (should be by default)
        New-NetFirewallRule -DisplayName "Allow RDP" -Direction Inbound -Protocol TCP -LocalPort 3389 -Action Allow -ErrorAction SilentlyContinue
        Write-LogEntry "RDP firewall rule verified"
        
        return $true
    }
    catch {
        Write-LogEntry "Error configuring firewall rules: $($_.Exception.Message)" "WARN"
        return $false
    }
}

# Function to optimize IIS settings
function Optimize-IISSettings {
    try {
        Write-LogEntry "Optimizing IIS settings..."
        
        # Import WebAdministration module
        Import-Module WebAdministration -ErrorAction SilentlyContinue
        
        # Set default document
        Set-WebConfigurationProperty -Filter "system.webServer/defaultDocument/files" -Name Collection -Value @{value="index.html"}
        Set-WebConfigurationProperty -Filter "system.webServer/defaultDocument/files" -Name Collection -Value @{value="iisstart.htm"} -Location "Default Web Site"
        
        # Enable compression
        Set-WebConfigurationProperty -Filter "system.webServer/httpCompression/scheme[@name='gzip']" -Name staticCompressionLevel -Value 9
        Set-WebConfigurationProperty -Filter "system.webServer/httpCompression/scheme[@name='gzip']" -Name dynamicCompressionLevel -Value 9
        
        # Configure logging
        Set-WebConfigurationProperty -Filter "system.webServer/httpLogging" -Name dontLog -Value $false
        
        Write-LogEntry "IIS optimization completed"
        return $true
    }
    catch {
        Write-LogEntry "Error optimizing IIS settings: $($_.Exception.Message)" "WARN"
        return $false
    }
}

# Function to test web server functionality
function Test-WebServer {
    try {
        Write-LogEntry "Testing web server functionality..."
        
        # Test local connectivity
        $response = Invoke-WebRequest -Uri "http://localhost" -UseBasicParsing -TimeoutSec 30
        
        if ($response.StatusCode -eq 200) {
            Write-LogEntry "Web server responding correctly (HTTP 200)"
            Write-LogEntry "Response length: $($response.Content.Length) characters"
            return $true
        } else {
            Write-LogEntry "Web server returned status code: $($response.StatusCode)" "WARN"
            return $false
        }
    }
    catch {
        Write-LogEntry "Error testing web server: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

# Function to display installation summary
function Show-InstallationSummary {
    param(
        [bool]$IISInstalled,
        [bool]$PageCreated,
        [bool]$FirewallConfigured,
        [bool]$IISOptimized,
        [bool]$WebServerTested
    )
    
    Write-LogEntry "=================== INSTALLATION SUMMARY ==================="
    Write-LogEntry "IIS Installation: $(if($IISInstalled) {'✅ SUCCESS'} else {'❌ FAILED'})"
    Write-LogEntry "Custom Page Creation: $(if($PageCreated) {'✅ SUCCESS'} else {'❌ FAILED'})"
    Write-LogEntry "Firewall Configuration: $(if($FirewallConfigured) {'✅ SUCCESS'} else {'❌ FAILED'})"
    Write-LogEntry "IIS Optimization: $(if($IISOptimized) {'✅ SUCCESS'} else {'❌ FAILED'})"
    Write-LogEntry "Web Server Test: $(if($WebServerTested) {'✅ SUCCESS'} else {'❌ FAILED'})"
    Write-LogEntry "=========================================================="
    
    $serverInfo = Get-ServerIdentifier
    Write-LogEntry "Server Identity: $($serverInfo.ServerName)"
    Write-LogEntry "Installation Log: $LogPath"
    Write-LogEntry "Web Root: $WebRootPath"
    
    if ($IISInstalled -and $PageCreated -and $WebServerTested) {
        Write-LogEntry "🎉 Installation completed successfully!" "SUCCESS"
        Write-LogEntry "Your web server is ready for load balancer testing."
    } else {
        Write-LogEntry "⚠️ Installation completed with some issues. Check the log for details." "WARN"
    }
}

# Main execution
try {
    Write-LogEntry "Starting Azure Load Balancer IIS Installation Script"
    Write-LogEntry "PowerShell Version: $($PSVersionTable.PSVersion)"
    Write-LogEntry "Execution Policy: $(Get-ExecutionPolicy)"
    
    # Execute installation steps
    $iisInstalled = Install-IISWebServer
    Start-Sleep -Seconds 5
    
    $pageCreated = New-CustomTestPage
    Start-Sleep -Seconds 2
    
    $firewallConfigured = Set-FirewallRules
    Start-Sleep -Seconds 2
    
    $iisOptimized = Optimize-IISSettings
    Start-Sleep -Seconds 2
    
    $webServerTested = Test-WebServer
    
    # Display summary
    Show-InstallationSummary -IISInstalled $iisInstalled -PageCreated $pageCreated -FirewallConfigured $firewallConfigured -IISOptimized $iisOptimized -WebServerTested $webServerTested
    
    Write-LogEntry "Script execution completed"
}
catch {
    Write-LogEntry "Fatal error during script execution: $($_.Exception.Message)" "ERROR"
    Write-LogEntry "Stack trace: $($_.ScriptStackTrace)" "ERROR"
    exit 1
}
