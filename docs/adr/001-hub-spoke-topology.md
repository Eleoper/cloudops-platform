# ADR-001: Hub-Spoke Network Topology

## Status
Accepted

## Context
We need a network architecture that isolates workloads, centralizes
connectivity, and scales to additional environments.

## Decision
Hub-spoke topology with:
- Hub VNet for shared services (Bastion, Firewall, VPN Gateway)
- Spoke VNets per environment (prod, dev)
- All inter-spoke traffic routed through hub

## Alternatives Considered
- **Flat VNet:** Simpler but no workload isolation. Blast radius is entire network.
- **Azure Virtual WAN:** More scalable but costs ~$0.05/hr minimum. Overkill for this project.
- **Mesh peering:** Spokes peer directly. Loses centralized egress control.

## Consequences
- Hub is a single point for connectivity management
- Adding a new environment = new spoke + peering (2 resources)
- Spoke-to-spoke traffic is inspectable at the hub firewall

## Problems Encountered
- VM sizes chosen from Claude were outdated. To fix this, I went to the dashboard to find the cheapest option viable for the lab.
- With the Firewall not enabled yet, the VMs that were designed to force route all traffic to it dropped. To test and verify that our small webpage in the vm was running smoothly, wihtout the network packets being sent to nowhere, I commented out the associated route tables that were being forced to the hub