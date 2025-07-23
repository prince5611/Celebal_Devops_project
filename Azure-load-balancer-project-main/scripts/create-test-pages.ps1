<#
.SYNOPSIS
    Creates custom test pages for Azure Load Balancer testing

.DESCRIPTION
    This script generates unique HTML test pages for each virtual machine
    in the load balancer backend pool, allowing for easy identification
    of which server is responding to requests.

.PARAMETER ServerNumber
    The server number (1 or 2) to generate appropriate content

.PARAMETER CustomMessage
    Optional custom message to include in the test page

.EXAMPLE
    .\create-test-pages.ps1 -ServerNumber 1
    .\create-test-pages.ps1 -ServerNumber 2 -CustomMessage "Production Server"
#>

param(
    [Parameter(Mandatory=$false)]
    [ValidateRange(1,10)]
    [int]$ServerNumber,
    
    [Parameter(Mandatory=$false)]
    [string]$CustomMessage = "",
    
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "C:\inetpub\wwwroot"
)

# Auto-detect server number if not provided
if (-not $ServerNumber) {
    $computerName = $env:COMPUTERNAME
    if ($computerName -match "vm1" -or $computerName -match "VM1") {
        $ServerNumber = 1
    } elseif ($computerName -match "vm2" -or $computerName -match "VM2") {
        $ServerNumber = 2
    } else {
        $ServerNumber = 1
        Write-Warning "Could not auto-detect server number. Using default: 1"
    }
}

# Define server-specific configurations
$serverConfigs = @{
    1 = @{
        Name = "lb-vm1"
        Color = "#e3f2fd"
        AccentColor = "#1976d2"
        Icon = "🚀"
        Theme = "Blue"
    }
    2 = @{
        Name = "lb-vm2" 
        Color = "#e8f5e8"
        AccentColor = "#388e3c"
        Icon = "🌟"
        Theme = "Green"
    }
}

# Get configuration for current server
$config = $serverConfigs[$ServerNumber]
if (-not $config) {
    Write-Error "Invalid server number: $ServerNumber"
    exit 1
}

# Generate test page content
function New-TestPageContent {
    param($Config, $ServerNum, $Message)
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $hostname = $env:COMPUTERNAME
    $ipAddress = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.PrefixOrigin -eq "Dhcp" }).IPAddress
    
    return @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Load Balancer Test - Server $ServerNum</title>
    <style>
        body { 
            font-family: 'Segoe UI', Arial, sans-serif;
            background: linear-gradient(135deg, $($Config.Color) 0%, #ffffff 100%);
            margin: 0;
            padding: 20px;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .container {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            max-width: 600px;
            text-align: center;
            backdrop-filter: blur(10px);
        }
        
        h1 { 
            color: $($Config.AccentColor);
            font-size: 2.5em;
            margin-bottom: 20px;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.1);
        }
        
        .server-info {
            background: linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%);
            border-radius: 15px;
            padding: 30px;
            margin: 20px 0;
            border-left: 5px solid $($Config.AccentColor);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.08);
        }
        
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin: 20px 0;
        }
        
        .info-item {
            background: rgba($($Config.AccentColor), 0.05);
            padding: 15px;
            border-radius: 10px;
        }
        
        .status-online {
            background: #28a745;
            color: white;
            padding: 8px 16px;
            border-radius: 20px;
            display: inline-block;
            margin: 10px 0;
        }
        
        .custom-message {
            background: rgba($($Config.AccentColor), 0.1);
            border-radius: 10px;
            padding: 20px;
            margin: 20px 0;
            font-style: italic;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>$($Config.Icon) Hello from $($Config.Name)!</h1>
        
        <div class="server-info">
            <h2>Azure Load Balancer Test Page</h2>
            <div class="status-online">✅ Server Online</div>
            
            <div class="info-grid">
                <div class="info-item">
                    <strong>Server:</strong> $($Config.Name)
                </div>
                <div class="info-item">
                    <strong>Hostname:</strong> $hostname
                </div>
                <div class="info-item">
                    <strong>IP Address:</strong> $ipAddress
                </div>
                <div class="info-item">
                    <strong>Theme:</strong> $($Config.Theme)
                </div>
                <div class="info-item">
                    <strong>Generated:</strong> $timestamp
                </div>
                <div class="info-item">
                    <strong>Current Time:</strong> <span id="live-time"></span>
                </div>
            </div>
            
            $(if ($Message) { "<div class='custom-message'><strong>Message:</strong> $Message</div>" })
        </div>
        
        <p>This page is served by <strong>Server $ServerNum</strong> in your Azure Load Balancer backend pool.</p>
        <p>Refresh this page multiple times to see load balancing in action!</p>
    </div>
    
    <script>
        function updateTime() {
            document.getElementById('live-time').textContent = new Date().toLocaleString();
        }
        updateTime();
        setInterval(updateTime, 1000);
    </script>
</body>
</html>
"@
}

# Create the test page
try {
    Write-Host "Creating test page for Server $ServerNumber ($($config.Name))" -ForegroundColor Green
    
    # Ensure output directory exists
    if (-not (Test-Path $OutputPath)) {
        New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
    }
    
    # Generate content
    $content = New-TestPageContent -Config $config -ServerNum $ServerNumber -Message $CustomMessage
    
    # Write to files
    $content | Out-File -FilePath "$OutputPath\index.html" -Encoding UTF8 -Force
    $content | Out-File -FilePath "$OutputPath\iisstart.htm" -Encoding UTF8 -Force
    
    Write-Host "✅ Test pages created successfully!" -ForegroundColor Green
    Write-Host "   - index.html: $OutputPath\index.html" -ForegroundColor Cyan
    Write-Host "   - iisstart.htm: $OutputPath\iisstart.htm" -ForegroundColor Cyan
    Write-Host "   - Server: $($config.Name)" -ForegroundColor Cyan
    Write-Host "   - Theme: $($config.Theme)" -ForegroundColor Cyan
}
catch {
    Write-Error "Failed to create test pages: $($_.Exception.Message)"
    exit 1
}
