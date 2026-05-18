# k8s-lab

Azure Bicep templates to provision a self-managed Kubernetes lab environment on Azure — 1 control plane node + 2 worker nodes, deployed via IaC.

## Architecture

```
Subscription
└── rg-k8s-lab
    ├── vnet-k8s (10.0.0.0/16)
    │   ├── snet-controlplane (10.0.1.0/24)
    │   │   └── vm-controlplane  — 10.0.1.10
    │   └── snet-workers (10.0.2.0/24)
    │       ├── vm-worker-1      — 10.0.2.11
    │       └── vm-worker-2      — 10.0.2.12
    └── nsg-k8s
        ├── Allow SSH (port 22) from your IP only
        ├── Allow Kubernetes API (port 6443) inbound
        └── Allow all intra-VNet traffic
```

## VM Specs

| Resource | Value |
|---|---|
| Image | Ubuntu Server 22.04 LTS |
| Size | Standard_B2s (2 vCPU / 4 GB RAM) |
| OS Disk | 30 GB |
| Auth | SSH key only (password disabled) |
| Public IP | Static, per VM |

## Prerequisites

- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Bicep CLI](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install) or Azure CLI ≥ 2.20
- An Azure subscription
- An SSH key pair

## Usage

**1. Fill in parameters**

Copy and edit `main.bicepparam`:

```bicep
param location      = 'southeastasia'   // Azure region
param yourIp        = 'x.x.x.x/32'     // Your public IP for SSH access
param adminUsername = 'azureuser'
param sshPublicKey  = 'ssh-rsa AAAA...'
```

**2. Login to Azure**

```bash
az login
az account set --subscription <subscription-id>
```

**3. Deploy**

```bash
az deployment sub create \
  --location southeastasia \
  --template-file main.bicep \
  --parameters main.bicepparam
```

**4. SSH into nodes**

```bash
# Control plane
ssh azureuser@<vm-controlplane-public-ip>

# Workers
ssh azureuser@<vm-worker-1-public-ip>
ssh azureuser@<vm-worker-2-public-ip>
```

## File Structure

```
k8s-lab/
├── main.bicep           # Subscription-scoped root template
├── main.bicepparam      # Parameter file
└── modules/
    ├── nsg.bicep        # Network Security Group + rules
    ├── network.bicep    # VNet + subnets
    └── vm.bicep         # VM, NIC, public IP (reusable)
```

## Next Steps

After provisioning, install Kubernetes on the nodes:

- [kubeadm setup guide](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)
- Initialize control plane: `kubeadm init`
- Join workers: `kubeadm join`
