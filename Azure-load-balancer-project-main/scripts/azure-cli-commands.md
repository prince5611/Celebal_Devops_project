# Azure CLI Commands for Load Balancer Project

## Complete Command Reference for Infrastructure Deployment

---

### Prerequisites

Install Azure CLI (if not already installed):

- **Windows:** [Download from https://aka.ms/installazurecliwindows](https://aka.ms/installazurecliwindows)
- **macOS:**
  ```sh
  brew install azure-cli
  ```
- **Linux:**
  ```sh
  curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
  ```

Login to Azure:

```sh
az login
```

Set default subscription:

```sh
az account set --subscription "Your-Subscription-ID"
```

Install required extensions:

```sh
az extension add --name application-gateway
```

---

### Variables Setup

Define common variables:

```sh
RESOURCE_GROUP="rg-loadbalancer-project"
LOCATION="eastus"
VNET_NAME="vnet-loadbalancer"
SUBNET_BACKEND="subnet-backend"
SUBNET_BASTION="AzureBastionSubnet"
NSG_NAME="nsg-backend"
LB_NAME="lb-public"
NAT_GATEWAY="nat-gateway-lb"
VM1_NAME="lb-vm1"
VM2_NAME="lb-vm2"
ADMIN_USERNAME="azureuser"
```

---

### 1. Resource Group Creation

Create resource group:

```sh
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION \
  --tags Environment=Learning Project=LoadBalancer Owner=Student
```

Verify creation:

```sh
az group show --name $RESOURCE_GROUP --output table
```

---

### 2. Virtual Network and Subnets

Create virtual network:

```sh
az network vnet create \
  --resource-group $RESOURCE_GROUP \
  --name $VNET_NAME \
  --address-prefix 10.0.0.0/16 \
  --location $LOCATION
```

Create backend subnet:

```sh
az network vnet subnet create \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --name $SUBNET_BACKEND \
  --address-prefix 10.0.0.0/24
```

Create Azure Bastion subnet:

```sh
az network vnet subnet create \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --name $SUBNET_BASTION \
  --address-prefix 10.0.1.0/26
```

Verify subnets:

```sh
az network vnet subnet list \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --output table
```

---

### 3. Network Security Group

Create NSG:

```sh
az network nsg create \
  --resource-group $RESOURCE_GROUP \
  --name $NSG_NAME \
  --location $LOCATION
```

Add HTTP rule:

```sh
az network nsg rule create \
  --resource-group $RESOURCE_GROUP \
  --nsg-name $NSG_NAME \
  --name AllowHTTP \
  --protocol tcp \
  --direction inbound \
  --source-address-prefix '' \
  --source-port-range '' \
  --destination-address-prefix '*' \
  --destination-port-range 80 \
  --access allow \
  --priority 100
```

Add RDP rule:

```sh
az network nsg rule create \
  --resource-group $RESOURCE_GROUP \
  --nsg-name $NSG_NAME \
  --name AllowRDP \
  --protocol tcp \
  --direction inbound \
  --source-address-prefix '' \
  --source-port-range '' \
  --destination-address-prefix '*' \
  --destination-port-range 3389 \
  --access allow \
  --priority 110
```

Associate NSG with subnet:

```sh
az network vnet subnet update \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --name $SUBNET_BACKEND \
  --network-security-group $NSG_NAME
```

---

### 4. NAT Gateway

Create public IP for NAT Gateway:

```sh
az network public-ip create \
  --resource-group $RESOURCE_GROUP \
  --name pip-nat-gateway \
  --sku Standard \
  --allocation-method Static \
  --location $LOCATION
```

Create NAT Gateway:

```sh
az network nat gateway create \
  --resource-group $RESOURCE_GROUP \
  --name $NAT_GATEWAY \
  --public-ip-addresses pip-nat-gateway \
  --location $LOCATION \
  --idle-timeout 10
```

Associate NAT Gateway with subnet:

```sh
az network vnet subnet update \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --name $SUBNET_BACKEND \
  --nat-gateway $NAT_GATEWAY
```

---

### 5. Load Balancer Setup

Create public IP for load balancer:

```sh
az network public-ip create \
  --resource-group $RESOURCE_GROUP \
  --name pip-loadbalancer \
  --sku Standard \
  --allocation-method Static \
  --location $LOCATION
```

Create load balancer:

```sh
az network lb create \
  --resource-group $RESOURCE_GROUP \
  --name $LB_NAME \
  --sku Standard \
  --public-ip-address pip-loadbalancer \
  --frontend-ip-name frontend-config \
  --backend-pool-name backend-pool \
  --location $LOCATION
```

Create health probe:

```sh
az network lb probe create \
  --resource-group $RESOURCE_GROUP \
  --lb-name $LB_NAME \
  --name health-probe-http \
  --protocol http \
  --port 80 \
  --path /
```

Create load balancing rule:

```sh
az network lb rule create \
  --resource-group $RESOURCE_GROUP \
  --lb-name $LB_NAME \
  --name http-rule \
  --protocol tcp \
  --frontend-port 80 \
  --backend-port 80 \
  --frontend-ip-name frontend-config \
  --backend-pool-name backend-pool \
  --probe-name health-probe-http
```

---

### 6. Virtual Machines

Create VM1:

```sh
az vm create \
  --resource-group $RESOURCE_GROUP \
  --name $VM1_NAME \
  --image Win2022Datacenter \
  --size Standard_B2s \
  --admin-username $ADMIN_USERNAME \
  --generate-ssh-keys \
  --vnet-name $VNET_NAME \
  --subnet $SUBNET_BACKEND \
  --nsg $NSG_NAME \
  --public-ip-address "" \
  --location $LOCATION \
  --zone 1
```

Create VM2:

```sh
az vm create \
  --resource-group $RESOURCE_GROUP \
  --name $VM2_NAME \
  --image Win2022Datacenter \
  --size Standard_B2s \
  --admin-username $ADMIN_USERNAME \
  --generate-ssh-keys \
  --vnet-name $VNET_NAME \
  --subnet $SUBNET_BACKEND \
  --nsg $NSG_NAME \
  --public-ip-address "" \
  --location $LOCATION \
  --zone 1
```

Add VMs to load balancer backend pool:

```sh
az network nic ip-config address-pool add \
  --resource-group $RESOURCE_GROUP \
  --nic-name ${VM1_NAME}VMNic \
  --ip-config-name ipconfig1 \
  --lb-name $LB_NAME \
  --address-pool backend-pool

az network nic ip-config address-pool add \
  --resource-group $RESOURCE_GROUP \
  --nic-name ${VM2_NAME}VMNic \
  --ip-config-name ipconfig1 \
  --lb-name $LB_NAME \
  --address-pool backend-pool
```

---

### 7. Verification Commands

Check resource group contents:

```sh
az resource list --resource-group $RESOURCE_GROUP --output table
```

Check load balancer status:

```sh
az network lb show \
  --resource-group $RESOURCE_GROUP \
  --name $LB_NAME \
  --query '{Name:name,SKU:sku.name,Frontend:frontendIpConfigurations.publicIpAddress.id}' \
  --output table
```

Check backend pool members:

```sh
az network lb address-pool show \
  --resource-group $RESOURCE_GROUP \
  --lb-name $LB_NAME \
  --name backend-pool \
  --query 'backendIpConfigurations[].{VM:id,PrivateIP:privateIpAddress}' \
  --output table
```

Check VM status:

```sh
az vm list \
  --resource-group $RESOURCE_GROUP \
  --show-details \
  --query '[].{Name:name,Status:powerState,Size:hardwareProfile.vmSize,PrivateIP:privateIps}' \
  --output table
```

Get load balancer public IP:

```sh
az network public-ip show \
  --resource-group $RESOURCE_GROUP \
  --name pip-loadbalancer \
  --query ipAddress \
  --output tsv
```

---

### 8. Monitoring and Diagnostics

Enable boot diagnostics for VMs:

```sh
az vm boot-diagnostics enable \
  --resource-group $RESOURCE_GROUP \
  --name $VM1_NAME

az vm boot-diagnostics enable \
  --resource-group $RESOURCE_GROUP \
  --name $VM2_NAME
```

Check NSG effective rules:

```sh
az network nsg show \
  --resource-group $RESOURCE_GROUP \
  --name $NSG_NAME
```
