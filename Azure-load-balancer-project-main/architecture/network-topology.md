# Network Topology Documentation

## Virtual Network Design
- **Address Space**: 10.0.0.0/16
- **Subnet Segmentation**: Backend and Bastion subnets
- **NAT Gateway Integration**: Outbound internet connectivity

## Load Balancer Configuration
- **SKU**: Standard
- **Distribution Mode**: 5-tuple hash
- **Health Probe**: HTTP on port 80

## Security Architecture
- **NSG Rules**: HTTP (80) and RDP (3389)
- **Private IP Range**: 10.0.0.0/24 for backend VMs
- **Public IP**: Static assignment for load balancer
