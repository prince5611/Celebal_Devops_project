# Step-by-Step Tutorial: Azure Load Balancer Deployment

## Complete Walkthrough for E-commerce Platform Load Balancing

### 🎯 Tutorial Overview

This tutorial provides detailed, step-by-step instructions for implementing an Azure Load Balancer solution to handle traffic spikes for a growing e-commerce platform. Follow each step carefully to ensure proper configuration.

## 📅 Estimated Time: 2-3 Hours

### Time Breakdown:

- **Infrastructure Setup**: 45 minutes
- **VM Deployment**: 30 minutes
- **Web Server Configuration**: 30 minutes
- **Testing and Validation**: 30 minutes
- **Documentation**: 15 minutes

---

## 🏁 Step 1: Create Resource Group

**Duration**: 5 minutes  
**Purpose**: Organize all project resources in a single container

### Detailed Instructions:

1. **Access Azure Portal**

   - Open web browser and navigate to [portal.azure.com](https://portal.azure.com)
   - Sign in with your Azure credentials
   - Wait for the dashboard to load completely

2. **Navigate to Resource Groups**

   - Click on "Resource groups" in the left navigation menu
   - If not visible, click "All services" and search for "Resource groups"
   - Click on the Resource groups service

3. **Create New Resource Group**

   - Click the "+ Create" button (blue button at the top)
   - Fill in the required information:
     - **Subscription**: Select your Azure subscription
     - **Resource group name**: `rg-loadbalancer-project`
     - **Region**: East US (or your preferred region)
   - Click "Review + create"
   - Review the settings and click "Create"
   - Wait for deployment completion (30-60 seconds)

4. **Verification**
   - Click "Go to resource" to view the empty resource group
   - Note the resource group name and region for future reference

---

## 🌐 Step 2: Create Virtual Network and Subnets

**Duration**: 10 minutes  
**Purpose**: Establish network infrastructure with proper segmentation

### Detailed Instructions:

1. **Navigate to Virtual Networks**

   - In the search bar at the top, type "Virtual networks"
   - Click on "Virtual networks" from the dropdown
   - Click "+ Create" to start the wizard

2. **Configure Basic Settings**

   - **Subscription**: Same as your resource group
   - **Resource group**: `rg-loadbalancer-project`
   - **Name**: `vnet-loadbalancer`
   - **Region**: East US (same as resource group)
   - Click "Next: IP Addresses"

3. **Configure IP Address Space**

   - **IPv4 address space**: Ensure it shows `10.0.0.0/16`
   - If different, change to `10.0.0.0/16`
   - Remove any existing default subnets by clicking the trash icon

4. **Add Backend Subnet**

   - Click "+ Add subnet"
   - **Subnet name**: `subnet-backend`
   - **Subnet address range**: `10.0.0.0/24`
   - Leave other settings as default
   - Click "Add"

5. **Add Azure Bastion Subnet**

   - Click "+ Add subnet" again
   - **Subnet name**: `AzureBastionSubnet` (exact name required)
   - **Subnet address range**: `10.0.1.0/26`
   - Leave other settings as default
   - Click "Add"

6. **Complete Creation**
   - Click "Review + create"
   - Verify both subnets are listed correctly
   - Click "Create"
   - Wait for deployment (2-3 minutes)

### Expected Result:

Your virtual network should show:

- Address space: 10.0.0.0/16
- subnet-backend: 10.0.0.0/24
- AzureBastionSubnet: 10.0.1.0/26

---

## 🚀 Step 3: Create NAT Gateway

**Duration**: 8 minutes  
**Purpose**: Provide secure outbound internet access for VMs

### Detailed Instructions:

1. **Search for NAT Gateway**

   - In the Azure portal search bar, type "NAT gateway"
   - Click on "NAT gateways" from the results
   - Click "+ Create"

2. **Configure Basic Settings**

   - **Subscription**: Same as previous resources
   - **Resource group**: `rg-loadbalancer-project`
   - **Name**: `nat-gateway-lb`
   - **Region**: East US
   - **Availability zone**: Select "No zone" if zone-redundant isn't available
   - **TCP idle timeout**: 10 minutes

3. **Configure Outbound IP**

   - Click "Next: Outbound IP" or the "Outbound IP" tab
   - Click "Create a new public IP address"
   - **Name**: `pip-nat-gateway`
   - **SKU**: Standard
   - Leave other settings as default
   - Click "OK"

4. **Associate with Subnet**

   - Click "Next: Subnet" or the "Subnet" tab
   - **Virtual network**: Select `vnet-loadbalancer`
   - **Subnet**: Check the box for `subnet-backend`
   - Do NOT select AzureBastionSubnet

5. **Complete Creation**
   - Click "Review + create"
   - Verify configuration shows:
     - NAT gateway name: nat-gateway-lb
     - Public IP: pip-nat-gateway
     - Associated subnet: subnet-backend
   - Click "Create"
   - Wait for deployment (3-5 minutes)

---

## 🌍 Step 4: Create Public IP for Load Balancer

**Duration**: 3 minutes  
**Purpose**: Provide a static frontend IP address for the load balancer

### Detailed Instructions:

1. **Navigate to Public IP Addresses**

   - Search for "Public IP addresses" in the portal
   - Click on the service from results
   - Click "+ Create"

2. **Configure Public IP**

   - **Subscription**: Same as other resources
   - **Resource group**: `rg-loadbalancer-project`
   - **Name**: `pip-loadbalancer`
   - **Region**: East US
   - **SKU**: Standard
   - **IP Version**: IPv4
   - **IP address assignment**: Static
   - **Availability zone**: Zone-redundant (or "No zone" if unavailable)

3. **Complete Creation**
   - Leave DNS name label empty
   - Click "Review + create"
   - Click "Create"
   - Wait for deployment (30-60 seconds)
   - Note the assigned IP address for later testing

---

## ⚖️ Step 5: Create Azure Load Balancer

**Duration**: 12 minutes  
**Purpose**: Configure Layer 4 load balancing for traffic distribution

### Detailed Instructions:

1. **Navigate to Load Balancers**

   - Search for "Load balancers" in the portal
   - Click on "Load balancers"
   - Click "+ Create"

2. **Configure Basic Settings**

   - **Subscription**: Same as other resources
   - **Resource group**: `rg-loadbalancer-project`
   - **Name**: `lb-public`
   - **Region**: East US
   - **SKU**: Standard
   - **Type**: Public
   - **Tier**: Regional

3. **Configure Frontend IP**

   - Click "Next: Frontend IP configuration"
   - Click "+ Add a frontend IP configuration"
   - **Name**: `frontend-config`
   - **IP type**: Public IP address
   - **Public IP address**: Select `pip-loadbalancer`
   - Click "OK"

4. **Configure Backend Pool**

   - Click "Next: Backend pools"
   - Click "+ Add a backend pool"
   - **Name**: `backend-pool`
   - **Virtual network**: `vnet-loadbalancer`
   - **Backend Pool Configuration**: IP Address
   - Leave IP configurations empty for now
   - Click "Add"

5. **Configure Load Balancing Rules**

   - Click "Next: Inbound rules"
   - Under "Load balancing rule", click "+ Add a load balancing rule"
   - **Name**: `http-rule`
   - **IP Version**: IPv4
   - **Frontend IP address**: `frontend-config`
   - **Protocol**: TCP
   - **Port**: 80
   - **Backend port**: 80
   - **Backend pool**: `backend-pool`
   - **Health probe**: Create new
     - **Name**: `health-probe-http`
     - **Protocol**: HTTP
     - **Port**: 80
     - **Path**: `/`
     - Click "OK"
   - **Session persistence**: None
   - **Idle timeout**: 15 minutes
   - **TCP reset**: Enabled
   - Click "Add"

6. **Complete Creation**
   - Skip "Outbound rules" and "Tags"
   - Click "Review + create"
   - Verify all configurations
   - Click "Create"
   - Wait for deployment (3-5 minutes)

---

## 🛡️ Step 6: Create Network Security Group

**Duration**: 7 minutes  
**Purpose**: Configure firewall rules for VM security

### Detailed Instructions:

1. **Navigate to Network Security Groups**

   - Search for "Network security groups"
   - Click on the service
   - Click "+ Create"

2. **Configure Basic Settings**

   - **Subscription**: Same as other resources
   - **Resource group**: `rg-loadbalancer-project`
   - **Name**: `nsg-backend`
   - **Region**: East US
   - Click "Review + create"
   - Click "Create"
   - Wait for deployment

3. **Add HTTP Rule**

   - Click "Go to resource" after deployment
   - Click "Inbound security rules" under Settings
   - Click "+ Add"
   - **Source**: Any
   - **Source port ranges**: \*
   - **Destination**: Any
   - **Service**: HTTP (this sets destination port to 80)
   - **Action**: Allow
   - **Priority**: 100
   - **Name**: `AllowHTTP`
   - **Description**: "Allow HTTP traffic for web servers"
   - Click "Add"

4. **Add RDP Rule**

   - Click "+ Add" again
   - **Source**: Any
   - **Source port ranges**: \*
   - **Destination**: Any
   - **Service**: RDP (this sets destination port to 3389)
   - **Action**: Allow
   - **Priority**: 110
   - **Name**: `AllowRDP`
   - **Description**: "Allow RDP for VM management"
   - Click "Add"

5. **Associate with Subnet**
   - Click "Subnets" under Settings
   - Click "+ Associate"
   - **Virtual network**: `vnet-loadbalancer`
   - **Subnet**: `subnet-backend`
   - Click "OK"

---

## 💻 Step 7: Create Virtual Machine 1 (lb-vm1)

**Duration**: 8 minutes  
**Purpose**: Deploy the first backend web server

### Detailed Instructions:

1. **Navigate to Virtual Machines**

   - Search for "Virtual machines"
   - Click on the service
   - Click "+ Create" → "Azure virtual machine"

2. **Configure Basic Settings**

   - **Subscription**: Same as other resources
   - **Resource group**: `rg-loadbalancer-project`
   - **Virtual machine name**: `lb-vm1`
   - **Region**: East US
   - **Availability options**: Availability zone
   - **Availability zone**: Zone 1
   - **Security type**: Standard
   - **Image**: Windows Server 2022 Datacenter - Gen2
   - **VM architecture**: x64
   - **Size**: Standard_B2s (or available size)
   - **Username**: `azureuser`
   - **Password**: Create a strong password (save it!)
   - **Confirm password**: Re-enter the password
   - **Public inbound ports**: None

3. **Configure Disks**

   - Click "Next: Disks"
   - **OS disk type**: Premium SSD (recommended)
   - Leave other settings as default

4. **Configure Networking**

   - Click "Next: Networking"
   - **Virtual network**: `vnet-loadbalancer`
   - **Subnet**: `subnet-backend`
   - **Public IP**: None
   - **NIC network security group**: Advanced
   - **Configure network security group**: `nsg-backend`
   - **Load balancing**: Yes
   - **Load balancing options**: Azure load balancer
   - **Select a load balancer**: `lb-public`
   - **Select a backend pool**: `backend-pool`
   - **Enable accelerated networking**: Yes (if available)

5. **Complete Creation**
   - Skip Management, Monitoring, Advanced tabs (use defaults)
   - Click "Review + create"
   - Review all settings carefully
   - Click "Create"
   - Wait for deployment (5-8 minutes)

---

## 💻 Step 8: Create Virtual Machine 2 (lb-vm2)

**Duration**: 8 minutes  
**Purpose**: Deploy the second backend web server for redundancy

### Detailed Instructions:

1. **Start VM2 Creation**

   - Go back to Virtual machines service
   - Click "+ Create" → "Azure virtual machine"

2. **Configure Identical Settings to VM1**

   - Use identical settings to VM1 except:
     - **Virtual machine name**: `lb-vm2`
     - **Availability zone**: Zone 1 (if Zone 2/3 unavailable)
     - **Password**: Use the same password as VM1
   - All other networking and configuration settings should match VM1

3. **Complete Creation**
   - Follow the same process as VM1
   - Click "Review + create"
   - Click "Create"
   - Wait for deployment

### Verification:

After both VMs are created:

- Go to Load balancer → Backend pools → backend-pool
- Verify both VMs appear in the pool
- Both should show "Running" status

---

## 🌐 Step 9: Install and Configure IIS Web Server

**Duration**: 20 minutes  
**Purpose**: Set up web servers on both VMs with unique content

### Part A: Connect to VM1

1. **Download RDP File for VM1**
   - Go to Virtual machines → `lb-vm1`
   - Click "Connect" → "RDP"
   - Download the RDP file
   - Open the RDP file
   - Enter credentials: username `azureuser` and your password
   - Click "Yes" on security warnings
   - Wait for Windows Server desktop to load

### Part B: Install IIS on VM1

1. **Open Server Manager**

   - Server Manager should open automatically
   - If not, click Start → Server Manager

2. **Add Web Server Role**

   - Click "Add roles and features"
   - Click "Next" on "Before You Begin"
   - Select "Role-based or feature-based installation"
   - Click "Next" (server should be selected)
   - Check "Web Server (IIS)" checkbox
   - Click "Add Features" when prompted
   - Click "Next" through remaining screens
   - Click "Install"
   - Wait for installation to complete (2-3 minutes)
   - Click "Close"

3. **Test IIS Installation**
   - Open Internet Explorer on the VM
   - Navigate to `http://localhost`
   - The IIS welcome page should be displayed

### Part C: Create Custom Test Page for VM1

1. **Create Custom HTML Page**
   - Open File Explorer
   - Navigate to `C:\inetpub\wwwroot\`
   - Right-click → New → Text Document
   - Name it `index.html`
   - Right-click the file → "Open with" → Notepad
   - Replace all content with:

```html
<!DOCTYPE html>
<html>
  <head>
    <title>Load Balancer Test - Server 1</title>
    <style>
      body {
        font-family: Arial, sans-serif;
        text-align: center;
        padding: 50px;
        background-color: #e3f2fd;
      }
      h1 {
        color: #1976d2;
      }
      .server-info {
        background-color: white;
        padding: 20px;
        border-radius: 10px;
        margin: 20px auto;
        max-width: 500px;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
      }
    </style>
  </head>
  <body>
    <h1>🚀 Hello from VM1!</h1>
    <div class="server-info">
      <h2>Load Balancer Test Page</h2>
      <p><strong>Server:</strong> lb-vm1</p>
      <p><strong>Zone:</strong> Zone 1</p>
      <p><strong>Status:</strong> ✅ Web Server Running</p>
      <p>
        <strong>Timestamp:</strong>
        <script>
          document.write(new Date().toLocaleString());
        </script>
      </p>
    </div>
    <p>
      This page is served by the <strong>first</strong> backend server in your
      Azure Load Balancer configuration.
    </p>
  </body>
</html>
```

2. **Save the File**

   - Save the file (Ctrl+S)
   - Close Notepad

3. **Test Custom Page**
   - Refresh Internet Explorer
   - Navigate to `http://localhost`
   - The custom blue-themed page should be displayed

### Part D: Configure VM2 (Repeat Process)

1. **Connect to VM2**

   - Download and open RDP file for `lb-vm2`
   - Connect using same credentials

2. **Install IIS on VM2**

   - Follow the same IIS installation steps as VM1

3. **Create Custom Test Page for VM2**
   - Create `index.html` in `C:\inetpub\wwwroot\`
   - Use this content (note the different styling):

```html
<!DOCTYPE html>
<html>
  <head>
    <title>Load Balancer Test - Server 2</title>
    <style>
      body {
        font-family: Arial, sans-serif;
        text-align: center;
        padding: 50px;
        background-color: #e8f5e8;
      }
      h1 {
        color: #388e3c;
      }
      .server-info {
        background-color: white;
        padding: 20px;
        border-radius: 10px;
        margin: 20px auto;
        max-width: 500px;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
      }
    </style>
  </head>
  <body>
    <h1>🌟 Hello from VM2!</h1>
    <div class="server-info">
      <h2>Load Balancer Test Page</h2>
      <p><strong>Server:</strong> lb-vm2</p>
      <p><strong>Zone:</strong> Zone 1</p>
      <p><strong>Status:</strong> ✅ Web Server Running</p>
      <p>
        <strong>Timestamp:</strong>
        <script>
          document.write(new Date().toLocaleString());
        </script>
      </p>
    </div>
    <p>
      This page is served by the <strong>second</strong> backend server in your
      Azure Load Balancer configuration.
    </p>
  </body>
</html>
```

4. **Test VM2 Page**
   - Navigate to `http://localhost` on VM2
   - The green-themed page should be displayed

---

## 🧪 Step 10: Test Load Balancer Functionality

**Duration**: 15 minutes  
**Purpose**: Verify traffic distribution and high availability

### Test Procedure:

1. **Get Load Balancer Public IP**

   - Go to Load balancers → `lb-public`
   - Note the Frontend IP address (e.g., 134.33.140.72)

2. **Basic Connectivity Test**

   - Open a web browser on your local computer
   - Navigate to `http://[LOAD_BALANCER_IP]`
   - Either the VM1 (blue) or VM2 (green) page should be displayed

3. **Load Distribution Test**

   - Refresh the page multiple times (F5)
   - Responses should alternate between:
     - Blue page with "Hello from VM1!"
     - Green page with "Hello from VM2!"
   - This confirms load balancing is working

4. **Health Probe Verification**
   - Go to Azure portal → Load balancers → `lb-public`
   - Click "Backend pools" → `backend-pool`
   - Both VMs should show "Healthy" status

### Expected Results:

- Load balancer public IP is accessible
- Traffic alternates between VM1 and VM2
- Both VMs show healthy status
- Unique content displays from each server

---

## 🎯 Step 11: Final Verification and Documentation

**Duration**: 10 minutes  
**Purpose**: Confirm all components are working correctly

### Verification Checklist

#### Infrastructure Verification

- [ ] Resource group contains all created resources
- [ ] Virtual network has correct address space (10.0.0.0/16)
- [ ] Both subnets are properly configured
- [ ] NAT Gateway is associated with backend subnet
- [ ] NSG rules allow HTTP (80) and RDP (3389) traffic
- [ ] Load balancer has frontend IP and backend pool configured
- [ ] Both VMs are running and in the backend pool

#### Functionality Verification

- [ ] Load balancer public IP responds to HTTP requests
- [ ] Traffic distributes between both VMs
- [ ] Health probes show both VMs as healthy
- [ ] Each VM displays unique content (blue vs green)
- [ ] Timestamp updates on page refresh

#### Security Verification

- [ ] VMs have no public IP addresses
- [ ] NSG is associated with backend subnet
- [ ] RDP access works through VM connection
- [ ] Outbound internet access works via NAT Gateway
