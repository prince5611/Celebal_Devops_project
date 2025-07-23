# Azure Load Balancer for E-commerce Platform

## High-Availability Web Infrastructure with Zone Distribution

[![Azure](https://img.shields.io/badge/Azure-0078d4?style=for-the-badge&logo=microsoft-azure&logoColor=white)](https://azure.microsoft.com)
[![Load Balancer](https://img.shields.io/badge/Load_Balancer-Standard-blue?style=for-the-badge)](https://docs.microsoft.com/en-us/azure/load-balancer/)
[![Windows Server](https://img.shields.io/badge/Windows_Server-2022-0078d4?style=for-the-badge&logo=windows&logoColor=white)](https://www.microsoft.com/en-us/windows-server)

## 🎯 Project Overview

This project demonstrates the implementation of a **zone-redundant Azure Load Balancer** to address the scalability challenges of a growing e-commerce platform experiencing traffic spikes during peak hours. The solution provides high availability, automatic failover, and even traffic distribution across multiple virtual machines.

### 🚀 Business Problem Solved

- **Traffic Surges**: Handle increased demand during peak shopping periods
- **Downtime Prevention**: Eliminate single points of failure
- **Performance Optimization**: Distribute load evenly across multiple servers
- **Scalability**: Support business growth with elastic infrastructure

## 🏗️ Architecture Overview

Internet  
↓  
[Public IP: 134.33.140.72]  
↓  
[Azure Load Balancer (Standard SKU)]  
↓  
[Backend Pool - Zone Distribution]  
├── VM1 (Zone 1) - IIS Web Server  
└── VM2 (Zone 1) - IIS Web Server  
↓  
[Virtual Network: 10.0.0.0/16]  
├── Backend Subnet: 10.0.0.0/24  
└── Bastion Subnet: 10.0.1.0/26

## ✨ Key Features Implemented

### 🔧 **Infrastructure Components**

- [x] **Resource Group**: Centralized resource management
- [x] **Virtual Network**: Isolated network environment with custom subnets
- [x] **NAT Gateway**: Secure outbound internet connectivity
- [x] **Network Security Group**: Firewall rules for traffic control
- [x] **Public IP Address**: Static IP for load balancer frontend
- [x] **Azure Load Balancer**: Layer 4 load balancing with health probes

### 💻 **Virtual Machines**

- [x] **Dual VM Setup**: lb-vm1 and lb-vm2 for redundancy
- [x] **Zone Distribution**: VMs deployed across availability zones
- [x] **Windows Server 2022**: Latest server operating system
- [x] **IIS Web Server**: Internet Information Services for web hosting
- [x] **Custom Test Pages**: Unique content for load balancer verification

### 🔒 **Security & Access**

- [x] **Network Security Groups**: Port-based access control
- [x] **Private IP Addressing**: Backend VMs without public exposure
- [x] **Azure Bastion Ready**: Secure remote access infrastructure
- [x] **RDP Access Controls**: Managed remote desktop connectivity

### 📊 **Load Balancing Features**

- [x] **Health Probes**: HTTP-based availability monitoring
- [x] **Session Persistence**: Configurable client affinity
- [x] **Backend Pool Management**: Automatic VM registration
- [x] **Traffic Distribution**: Round-robin load balancing algorithm

## 💰 Cost Analysis

| Resource                     | Monthly Cost (USD) | Annual Cost (USD) |
| ---------------------------- | ------------------ | ----------------- |
| Load Balancer Standard       | $18.25             | $219.00           |
| Virtual Machines (2x D2s v3) | $140.16            | $1,681.92         |
| Public IP Address            | $3.65              | $43.80            |
| NAT Gateway                  | $32.85             | $394.20           |
| **Total Estimated Cost**     | **$194.91**        | **$2,338.92**     |

_Note: Costs based on East US region pricing and may vary_

## 📸 Screenshots & Proof of Concept

The following screenshots demonstrate the complete implementation of the Azure Load Balancer infrastructure:

### 1. Resource Group Creation

![Resource Group Creation](screenshots/01-resource-group-creation.png)
_Initial setup of the resource group to organize all infrastructure components_

### 2. Virtual Network Setup

![Virtual Network Setup](screenshots/02-virtual-network-setup.png)
_Configuration of the virtual network with custom address space and subnets_

### 3. NAT Gateway Configuration

![NAT Gateway Configuration](screenshots/03-nat-gateway-config.png)
_NAT Gateway setup for secure outbound internet connectivity_

### 4. Load Balancer Setup

![Load Balancer Setup](screenshots/04-load-balancer-setup.png)
_Azure Load Balancer configuration with backend pools and health probes_

### 5. Virtual Machine Deployment

![VM Deployment](screenshots/05-vm-deployment.png)
_Deployment of virtual machines across availability zones_

### 6. Network Security Group Configuration

![NSG Configuration](screenshots/06-nsg-configuration.png)
_Network Security Group rules for traffic control and security_

### 7. Final Architecture

![Final Architecture](screenshots/07-final-architecture.png)
_Complete infrastructure showing all components working together_

---

<!-- Continue with the rest of your README content as needed -->
