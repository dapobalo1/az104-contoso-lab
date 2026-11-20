#!/usr/bin/env bash
# Teardown for Project 2 (student subscription half).
# Default mode only deallocates VMs, because Projects 3 and 4 reuse them.
# Pass --full to delete everything Project 2 created.
#
# Usage: ./teardown/02-compute-governance.sh [--full]
set -euo pipefail

RGS=(rg-contoso-compute rg-contoso-compute-moved)
POLICY_NAMES=("contoso-allowed-locations-rg" "Require a tag on resource groups" "contoso-inherit-costcenter")

echo "Subscription: $(az account show --query name -o tsv)"
read -r -p "Continue? (y/N) " ok
[[ "$ok" == "y" ]] || exit 1

existing_rgs=()
for rg in "${RGS[@]}"; do
  if [[ "$(az group exists -n "$rg")" == "true" ]]; then existing_rgs+=("$rg"); fi
done
[[ ${#existing_rgs[@]} -gt 0 ]] || { echo "No Project 2 resource groups found."; exit 0; }

# 1. Remove resource locks, or deletes (and some stops) will fail.
for rg in "${existing_rgs[@]}"; do
  for id in $(az lock list -g "$rg" --query "[].id" -o tsv); do
    echo "Removing lock: ${id##*/}"
    az lock delete --ids "$id"
  done
done

# 2. Delete any scale set (step 2.8 says it is not needed later).
for rg in "${existing_rgs[@]}"; do
  for name in $(az vmss list -g "$rg" --query "[].name" -o tsv); do
    echo "Deleting scale set: $name"
    az vmss delete -g "$rg" -n "$name" --no-wait
  done
done

if [[ "${1:-}" == "--full" ]]; then
  # 3. Delete the resource groups (VMs, disks, NICs, VNet go with them).
  for rg in "${existing_rgs[@]}"; do
    echo "Deleting resource group: $rg"
    az group delete -n "$rg" --yes --no-wait
  done
  # 4. Delete the step 2.4 policy assignments (matched by display name).
  for pname in "${POLICY_NAMES[@]}"; do
    for id in $(az policy assignment list --query "[?displayName=='$pname'].id" -o tsv); do
      echo "Deleting policy assignment: $pname"
      az policy assignment delete --ids "$id"
    done
  done
  echo "Full teardown started. Budget is kept (it costs nothing)."
else
  # 5. Deallocate every VM. Stopped is not enough: only deallocated VMs
  #    stop compute billing (disks still bill a few cents a day).
  for rg in "${existing_rgs[@]}"; do
    ids=$(az vm list -g "$rg" --query "[].id" -o tsv)
    if [[ -n "$ids" ]]; then
      echo "Deallocating VMs in $rg"
      # shellcheck disable=SC2086
      az vm deallocate --ids $ids
    fi
  done
  az vm list -d --query "[].{name:name, rg:resourceGroup, power:powerState}" -o table
fi
