# AZ-104 Hands-On Build: Contoso Cloud Environment

**Owner:** Adedapo Balogun
**Purpose:** Pass AZ-104 by building one connected Azure environment across five projects, while producing portfolio material (GitHub repo, LinkedIn posts, resume bullets).
**Course:** AZ-104 Microsoft Azure Administrator, Scott Duffy (Udemy)
**Exam outline used:** Microsoft skills measured as of April 17, 2026

---

## How to use this guide

- Work the projects in order. Each one builds on the previous one.
- Projects 1 to 3 are catch-up projects (course sections already watched). Timebox each to 2 to 3 hours and keep watching the networking sections in parallel.
- Project 4 runs alongside section 17 onward. Project 5 runs alongside the monitoring and backup sections.
- Every step has a checkbox. Tick it in your repo copy as you go so Claude Code and you can both see progress.
- Every project ends with **Break it**, **Exam takeaways**, **Document it**, and **Teardown**. Do not skip Break it. The exam is built around misconfigurations.

### The scenario

You are the new Azure administrator for **Contoso**, a small company with an IT team, developers, finance, a helpdesk, and an intern. Leadership wants identity locked down, costs controlled, data protected, the network segmented, and everything monitored and backed up.

### Phase map

| # | Project | Main exam domain | Course timing |
|---|---|---|---|
| 1 | Entra ID + Conditional Access | Identities and governance | Catch-up |
| 2 | VMs + RBAC + Policy + Budgets + Bicep | Governance + Compute | Catch-up |
| 3 | Storage + access tiers | Storage | Catch-up |
| 4 | VNets + private endpoints + load balancing | Networking | Sections 17+ |
| 5 | Monitor + Log Analytics + Backup + Site Recovery | Monitor and maintain | Monitoring sections |
| Bonus | App Service + Containers | Compute | Any time after Project 4 |

---

## Part A: Ground rules for the environment

### A1. Subscription and account

> **As built (2026-10-27):** lab identity runs in a dedicated tenant I own, with a native Global Administrator account. The Azure for Students subscription ($100) lives in the school tenant and cannot be moved (blocked by the school's subscription policy), and the Azure free account was not available. Paid resources go on the student subscription; steps that need Contoso users to hold RBAC roles are adjusted in Project 2.

- [x] Use a dedicated subscription for this lab. Check if you qualify for **Azure for Students** through your WGU email (no credit card, includes credit). Otherwise use pay-as-you-go with a budget (Project 2, step 1).
- [ ] Sign in to the [Azure portal](https://portal.azure.com) and the [Entra admin center](https://entra.microsoft.com). Confirm your account is **Global Administrator** in the tenant and **Owner** on the subscription.
- [ ] Install locally: Azure CLI, Bicep (`az bicep install`), Azure Storage Explorer, AzCopy, VS Code with the Bicep extension, Git.

### A2. Regions

- Primary: **East US 2**
- Secondary (Site Recovery in Project 5): **Central US**
- Stick to these two. Policy in Project 2 will enforce it.

### A3. Naming convention

`<type>-contoso-<purpose>` for most resources. Storage accounts cannot have dashes: `stcontoso<purpose><4 random chars>`.

| Resource | Example |
|---|---|
| Resource group | `rg-contoso-compute` |
| Virtual network | `vnet-contoso-hub` |
| Subnet | `snet-web` |
| VM | `vm-contoso-web01` |
| NSG | `nsg-contoso-web` |
| Storage account | `stcontosodata7k2p` |
| Log Analytics workspace | `law-contoso` |
| Recovery Services vault | `rsv-contoso` |

### A4. Required tags on every resource group

| Tag | Value example |
|---|---|
| `env` | `lab` |
| `owner` | `dapo` |
| `project` | `az104-p2` |
| `costcenter` | `it` |

### A5. Cost discipline

- Set the budget in Project 2 step 1 **before** creating any VM.
- End every session by running the project's teardown or by **deallocating** VMs (Stop in the portal, status must read `Stopped (deallocated)`).
- Expensive by the hour: Bastion (Basic/Standard), load balancers, VPN gateways, Site Recovery replication, Log Analytics ingestion. Delete these at the end of each session and redeploy with your Bicep or CLI scripts next time.
- Small VM sizes only: `Standard_B1s` or `Standard_B2ats_v2`.

---

## Part B: Documentation system

Set this up once before Project 1. It is what turns study time into portfolio material.

### B1. GitHub repo structure

Create a public repo named `az104-contoso-lab`:

```
az104-contoso-lab/
├── README.md                  # Portfolio landing page
├── CLAUDE.md                  # Instructions for Claude Code
├── docs/
│   ├── PROJECT_GUIDE.md       # This file
│   ├── architecture/          # Diagrams (.drawio + exported .png)
│   └── exam-notes.md          # Running list of exam takeaways
├── projects/
│   ├── 01-identity/
│   │   ├── README.md
│   │   ├── screenshots/
│   │   └── scripts/
│   ├── 02-compute-governance/
│   ├── 03-storage/
│   ├── 04-networking/
│   ├── 05-monitoring-backup/
│   └── bonus-app-service-containers/
└── teardown/                  # One teardown script per project
```

### B2. Screenshot rules

- **Name:** `PP-SS-short-description.png` (project number, step number). Example: `01-07-ca-policy-whatif.png`.
- **Capture:** the configuration screen, the result, and any error you hit. Errors make the best posts.
- **Redact before committing:** tenant ID, subscription ID, real email addresses, phone numbers, public IPs, storage keys, SAS tokens. Use a solid box, not blur.
- Take 4 to 8 per project. You will not use them all, but you cannot retake them after teardown.

### B3. Per-project README template

Copy this into each `projects/0X-*/README.md`:

```markdown
# Project X: <Title>

## Goal
One or two sentences on what Contoso needed.

## Summary
A short paragraph on what was built and why it matters, for anyone reading the repo.

## Architecture
![diagram](../../docs/architecture/0X-diagram.png)

## What I built
- Bullet per major resource or configuration

## Exam objectives covered
- [x] Objective text from the AZ-104 outline

## Break/fix log
| What I broke | Symptom | Root cause | Fix |
|---|---|---|---|

## Key takeaways
- Three to five lessons in your own words

## Scripts
- `scripts/deploy.sh` / `main.bicep`
- `../../teardown/0X-teardown.sh`

## Cost
Approximate spend for this project.
```

### B4. Break/fix log

This is the most valuable section for both the exam and interviews. For every error, record:

- **What I did** (the action)
- **What happened** (the exact error message, screenshot it)
- **Why** (the Azure rule behind it)
- **Fix**

Example entry: *Assigned a license to a user. Error: usage location required. Why: license assignment requires a usage location on the user object. Fix: set usage location to United States, then reassign.*

### B5. Exam notes file

After each project, add three to five lines to `docs/exam-notes.md` in this format:

```
- [P1] Dynamic groups require Entra ID P1. Rule syntax: (user.department -eq "Finance").
```

Feed this file into NotebookLM before the exam.

### B6. LinkedIn post template (one per project)

```
I'm building a full Azure environment for a fictional company while studying for AZ-104.

Project X: <title>

What I built:
• ...
• ...

What broke (and what it taught me):
<one specific error and the fix>

Biggest takeaway:
<one sentence>

Repo: <link>
#Azure #AZ104 #CloudEngineering
```

Attach the architecture diagram or the best error screenshot.

### B7. Resume bullet formula

**Action verb + what + Azure services + measurable result.**

Example: *Designed and deployed a hub-and-spoke Azure network with NSGs, application security groups, private endpoints, and an internal load balancer, removing all public exposure from storage and application tiers.*

Write one bullet per project and keep it outside the repo, with the LinkedIn drafts, in a private Career folder. Pick the best two or three for the resume at the end. The project README gets a Summary section instead.

### B8. Using this repo with Claude Code

- Put this file at `docs/PROJECT_GUIDE.md` and the provided `CLAUDE.md` at the repo root.
- Useful prompts:
  - "Read docs/PROJECT_GUIDE.md. I finished Project 2 step 5. Give me the Bicep skeleton for step 5 with TODOs."
  - "Write teardown/02-teardown.sh based on the resources in Project 2."
  - "Turn my break/fix notes in projects/03-storage/README.md into a LinkedIn post using the template in section B6."
  - "Check projects/04-networking/screenshots for any filenames that do not follow the naming rule."

---

## Project 1: Entra ID + Conditional Access

**Goal:** Contoso's people exist in Entra ID, organized into groups, licensed, able to reset their own passwords, and protected by Conditional Access.

**Exam objectives covered:** Create users and groups; manage user and group properties; manage licenses; manage external users; configure SSPR. Conditional Access and Entra roles are tested alongside these.

**Time:** 2 to 3 hours. **Cost:** $0 (trial license).

### Steps

#### 1.1 Prep
- [x] In the Entra admin center, note your tenant's default domain (`<something>.onmicrosoft.com`).
- [x] Start the **Microsoft Entra ID P2 trial**: Entra admin center > Billing > Licenses > All products > Try/Buy. P2 includes P1, which you need for Conditional Access, dynamic groups, group-based licensing, and SSPR. The trial lasts 30 days, so start it today.
- [x] Create a **break-glass account**: `breakglass@<domain>`, Global Administrator, long random password stored in a password manager. You will exclude it from every Conditional Access policy.

#### 1.2 Create users (three different methods)
Create these five users:

| User | Department | Job title |
|---|---|---|
| alex.admin | IT | Cloud Administrator |
| jordan.dev | Engineering | Developer |
| sam.finance | Finance | Analyst |
| riley.help | IT | Helpdesk |
| taylor.intern | Engineering | Intern |

- [x] **Portal:** create alex and jordan through Users > New user > Create new user. Set department, job title, and **usage location = United States**.
- [x] **Bulk create:** Users > Bulk operations > Bulk create. Download the CSV template, add sam and riley, upload, and check the bulk operation results page.
- [x] **CLI:** create taylor.

  ```bash
  az ad user create \
    --display-name "Taylor Intern" \
    --user-principal-name taylor.intern@<domain> \
    --password "<temp-password>" \
    --force-change-password-next-sign-in true
  ```
  Then set department and job title in the portal (the basic CLI command does not set them).
- [x] Deliberately leave **usage location blank** on taylor for step 1.4.

#### 1.3 Create groups
- [x] **Security group, assigned:** `grp-it-admins` with alex and riley. Set alex as group owner.
- [x] **Security group, assigned:** `grp-developers` with jordan and taylor.
- [x] **Security group, dynamic user:** `grp-finance` with rule `(user.department -eq "Finance")`. Confirm sam appears after a few minutes.
- [x] **Microsoft 365 group:** `m365-contoso-all`. Note how it differs from a security group (mailbox, Teams, SharePoint).
- [x] **Security group, assigned:** `grp-sspr-pilot` with jordan, sam, taylor.

#### 1.4 Licenses
- [x] Assign the Entra ID P2 license **to the group** `grp-it-admins` (group-based licensing): Groups > grp-it-admins > Licenses > Assignments.
- [x] Assign the license directly to taylor. It should fail because usage location is blank. Screenshot the error, set usage location, retry.
- [x] On alex's user object, view Licenses and note it shows as **Inherited** from the group.

#### 1.5 External users
- [x] Review External Identities > External collaboration settings. Note who can invite guests and the guest user access restriction levels.
- [x] Invite a guest using a personal email: Users > New user > Invite external user.
- [ ] Accept the invite from the personal mailbox. Back in Entra, note **User type = Guest** and the `#EXT#` in the UPN.

#### 1.6 Self-service password reset (SSPR)
- [x] Protection > Password reset > Properties: enabled for **Selected** > `grp-sspr-pilot`.
- [x] Authentication methods: number required = **2**; enable mobile app notification, email, and mobile phone.
- [x] Registration: require users to register at sign-in; reconfirm every 180 days.
- [x] Notifications: notify users on reset; notify admins when another admin resets.
- [ ] **(OPEN)** Test: open a private browser window, sign in as jordan, register methods, sign out, go to `https://aka.ms/sspr`, and reset the password.

#### 1.7 Entra roles (directory roles, not Azure RBAC)
- [x] Assign **Helpdesk Administrator** to riley: Roles and administrators > Helpdesk Administrator > Add assignments.
- [x] Sign in as riley and confirm riley can reset a non-admin user's password but cannot reset alex's (a higher-privileged admin).
- [x] Write the difference in your exam notes: **Entra roles control the directory (users, groups, licenses). Azure RBAC roles control Azure resources.** Project 2 covers RBAC.

#### 1.8 Conditional Access
- [x] Turn **off** Security defaults: Overview > Properties > Manage security defaults. Conditional Access and security defaults cannot run together.
- [x] Create a named location: Conditional Access > Named locations > Countries location > **United States**.
- [x] **Policy CA01: Require MFA for admins.** Users: `grp-it-admins`, exclude breakglass. Target resources: All cloud apps. Grant: Require multifactor authentication. State: **Report-only** first.
- [x] **Policy CA02: Block sign-ins outside the US.** Users: All users, exclude breakglass. Conditions > Locations: include Any location, exclude the United States named location. Grant: Block access. State: Report-only.
- [x] **Policy CA03: Block legacy authentication.** Users: All users, exclude breakglass. Conditions > Client apps: Exchange ActiveSync clients and Other clients. Grant: Block. State: Report-only.
- [x] Use the **What If** tool to simulate alex signing in from the US, and taylor from another country. Screenshot both results.
- [x] Switch CA01 to **On**. Sign in as alex in a private window and complete MFA registration.
- [x] Review Monitoring > **Sign-in logs** for alex. Open the Conditional Access tab on the sign-in event.

### Break it
- [ ] Usage location blank, license fails (skipped in 1.4: taylor's usage location was already set, so the direct assignment succeeded. To reproduce: remove the license, clear usage location, reassign).
- [x] Change the dynamic group rule to `(user.department -eq "finance ")` with a trailing space. Watch sam drop out. Fix it. (As built: trailing spaces did not break the match, so used the typo `"Finanse"` and proved it with Validate Rules.)
- [ ] Remove jordan from `grp-sspr-pilot` and attempt SSPR. Note the message. (Skipped: understood. Users outside the one selected SSPR group cannot use SSPR regardless of registered methods.)
- [x] Try to create a Conditional Access policy while security defaults are on. Note the block. (As built: tested the reverse. With CA policies active, the Manage security defaults link is removed and the portal says CA prevents enabling security defaults.)

### Exam takeaways
- Usage location is required before assigning a license.
- Dynamic groups and group-based licensing require P1 or higher.
- Guests have `#EXT#` in the UPN and User type = Guest.
- SSPR scope can be None, Selected (one group), or All.
- Conditional Access requires security defaults to be off and P1 or higher. Always exclude a break-glass account. Test in Report-only and What If before enforcing.
- Entra roles (directory) are separate from Azure RBAC roles (resources).

### Document it
- [x] Screenshots: users list, dynamic group rule + members, license inheritance, license error, guest user, SSPR settings, What If result, sign-in log CA tab.
- [x] Diagram: users > groups > licenses/policies (a simple box diagram is enough).
- [x] README, break/fix log, three to five exam notes, LinkedIn draft.

### Teardown
- **Keep everything.** Projects 2 to 5 use these users and groups.
- Put a calendar reminder for the P2 trial expiration date.

---

## Project 2: VMs + RBAC + Policy + Budgets + Bicep

**Goal:** Contoso's spending is capped and visible, resources are governed by policy and tags, developers can manage VMs without owning the subscription, and the VMs are deployed as code.

**Exam objectives covered:** Azure Policy; resource locks; tags; resource groups; subscriptions; costs with alerts, budgets, and Advisor; management groups; built-in roles; assigning roles at scopes; interpreting access; ARM and Bicep (interpret, modify, deploy, export, convert); create VMs; encryption at host; move VMs; VM sizes; disks; availability zones and sets; VM Scale Sets.

**Time:** 3 hours. **Cost:** a few dollars if VMs are deallocated after the session.

### Steps

#### 2.1 Budget first
- [ ] Cost Management > Budgets > Add. Scope: subscription. Amount: **$20/month** (adjust to your credit).
- [ ] Alerts: 50%, 80%, 100% **Actual**, and 100% **Forecasted**. Recipient: your email.
- [ ] Note: budgets alert, they do **not** stop resources.

#### 2.2 Management group and subscription
- [ ] Create management group `mg-contoso` and move your subscription under it.
- [ ] Note the hierarchy: Root management group > mg-contoso > subscription > resource groups > resources.

#### 2.3 Resource groups with tags
- [ ] Create `rg-contoso-compute`, `rg-contoso-compute-moved`, and `rg-contoso-storage` in East US 2 with the four tags from A4.

#### 2.4 Azure Policy
- [ ] Assign built-in **Allowed locations** at `mg-contoso`: East US 2 and Central US.
- [ ] Assign built-in **Require a tag on resource groups** with tag name `owner`.
- [ ] Assign built-in **Inherit a tag from the resource group if missing** with tag `costcenter`. This uses the **Modify** effect, so the assignment creates a managed identity. Create a **remediation task** for existing resources.
- [ ] Test: create a resource group in West Europe. It should be denied. Screenshot.
- [ ] Test: create a resource group without the `owner` tag. Denied.
- [ ] Open Policy > Compliance and review the compliance state (evaluation can take up to 30 minutes).

#### 2.5 Deploy VMs with Bicep
Create `projects/02-compute-governance/scripts/main.bicep`. Skeleton (ask Claude Code to fill the TODOs):

```bicep
param location string = resourceGroup().location
param adminUsername string
@secure()
param adminPassword string
param vmCount int = 2

// TODO: VNet vnet-contoso-app 10.1.0.0/16 with subnet snet-web 10.1.1.0/24

// TODO: NIC per VM (no public IP), loop with vmCount

// TODO: Linux VM per NIC
//   size: Standard_B1s
//   image: Ubuntu 24.04 LTS
//   zones: VM 1 in zone '1', VM 2 in zone '2'
//   tags: env, owner, project, costcenter

output vmNames array = [] // TODO
```

- [ ] Deploy:
  ```bash
  az deployment group create \
    --resource-group rg-contoso-compute \
    --template-file main.bicep \
    --parameters adminUsername=contosoadmin
  ```
- [ ] In the portal, open the resource group > Deployments and review the deployment record.
- [ ] Confirm the VMs have the `costcenter` tag (applied by policy if you left it out).

#### 2.6 Export and convert templates
- [ ] Resource group > Export template. Download the ARM JSON.
- [ ] Convert it: `az bicep decompile --file template.json`. Compare it to your original Bicep and note differences.
- [ ] Modify: change the VM size parameter in the ARM JSON, then redeploy it in the portal (Deploy a custom template > Build your own template in the editor).

#### 2.7 VM administration
- [ ] **Resize** vm-contoso-web01 to `Standard_B2ats_v2`. Note which sizes need a deallocate first.
- [ ] **Add a data disk** (Standard SSD, 32 GiB) to web01. Change the disk SKU to Standard HDD while the VM is deallocated.
- [ ] **Encryption at host:** register the feature, then enable it on web02 while deallocated.
  ```bash
  az feature register --namespace Microsoft.Compute --name EncryptionAtHost
  az provider register --namespace Microsoft.Compute
  ```
- [ ] **Move** web02 (with its NIC and disks) to `rg-contoso-compute-moved` using Move > Move to another resource group. Read the validation step. Note: moving to another subscription uses the same flow; moving to another **region** uses Azure Resource Mover.
- [ ] Use **Run command** > RunShellScript to run `hostname` on a VM (no public IP needed).

#### 2.8 Availability sets and scale sets
- [ ] Create an availability set `avail-contoso` with 2 fault domains and 5 update domains. Note: a VM can only be added to an availability set **at creation**, and a VM cannot be in both an availability set and a zone.
- [ ] Create a **VM Scale Set** (Flexible orchestration), 2 instances, `Standard_B1s`.
- [ ] Add an autoscale rule: scale out +1 when average CPU > 70% for 10 minutes; scale in -1 when < 30%; min 1, max 3.
- [ ] Manually scale to 1 instance. Then delete the scale set (it is not needed later).

#### 2.9 RBAC
- [ ] Assign **Virtual Machine Contributor** to `grp-developers` at `rg-contoso-compute` scope.
- [ ] Assign **Cost Management Reader** to sam at subscription scope.
- [ ] Assign **Reader** to riley at the scope of a single VM.
- [ ] Sign in as jordan: confirm jordan can restart a VM in rg-contoso-compute but cannot see `rg-contoso-storage`.
- [ ] Sign in as sam: confirm sam can open Cost analysis but cannot see VM settings.
- [ ] Use **Check access** on a resource group to view a user's effective assignments. Note which are inherited.
- [ ] Open the **Deny assignments** tab. Read what creates deny assignments (managed apps, deployment stacks), since you cannot create them directly.

#### 2.10 Locks
- [ ] Add a **CanNotDelete** lock to `rg-contoso-compute`. Try to delete a VM as Owner. Denied.
- [ ] Add a **ReadOnly** lock on web01. Try to stop or start it. Denied. Remove the lock.
- [ ] Note: locks override RBAC, even for Owner.

#### 2.11 Advisor
- [ ] Open Azure Advisor and review the Cost and Security recommendations. Screenshot one and write down what it recommends.

### Break it
- [ ] Policy deny on wrong region and missing tag (done in 2.4).
- [ ] Deploy Bicep with an invalid VM size or a typo in an API version. Read the error.
- [ ] Try to add an existing VM to an availability set.
- [ ] Try to delete a locked resource group.

### Exam takeaways
- Policy evaluates **resource properties** (what can exist). RBAC controls **who** can act. Locks block actions for **everyone**.
- Role assignments inherit downward: management group > subscription > resource group > resource.
- Policy effects: Deny, Audit, Modify, Append, DeployIfNotExists, AuditIfNotExists. Modify and DeployIfNotExists need a managed identity and remediation tasks for existing resources.
- Budgets only alert. They never stop resources.
- ReadOnly lock blocks POST operations too (start, stop, list keys).
- Availability set: same datacenter, protects against rack and update failures (99.95%). Availability zones: separate datacenters (99.99%).
- `az bicep decompile` converts ARM JSON to Bicep. Export template captures current state.

### Document it
- [ ] Screenshots: budget alerts, policy deny error, compliance view, Bicep deployment record, check access result, lock error, scale set autoscale rule.
- [ ] Commit `main.bicep` and the exported template.
- [ ] Diagram: management group > subscription > resource groups, with policies, RBAC assignments, and locks marked at their scope.
- [ ] README, break/fix log, exam notes, LinkedIn draft.

### Teardown
- [ ] Deallocate VMs. Keep them; Project 4 uses them.
- [ ] Remove the CanNotDelete lock so later teardown works. Keep policies and budget.

---

## Project 3: Storage + Access Tiers

**Goal:** Contoso stores documents and backups cheaply, with access limited to the right people and networks, protection against accidental deletion, and a file share mounted on a VM.

**Exam objectives covered:** Storage firewalls and virtual networks; SAS tokens; stored access policies; access keys; identity-based access for Azure Files; create and configure storage accounts; redundancy; object replication; encryption; Storage Explorer and AzCopy; file shares; containers; tiers; soft delete for blobs and containers; snapshots and soft delete for Azure Files; lifecycle management; versioning.

**Time:** 2 to 3 hours. **Cost:** cents.

### Steps

#### 3.1 Create storage accounts
- [ ] Create `stcontosodata<xxxx>` in `rg-contoso-storage`: Standard, StorageV2, **LRS**, East US 2. On the Advanced tab note **Allow storage account key access** and minimum TLS 1.2. On the Encryption tab note **infrastructure encryption** can only be enabled at creation.
- [ ] Create a second account `stcontosorepl<xxxx>` in Central US, LRS (target for object replication).
- [ ] Change redundancy on the first account from LRS to **GRS** in Redundancy settings. Then try selecting ZRS and read why it requires a conversion.

#### 3.2 Containers and data movement
- [ ] Create container `documents` with access level **Private**.
- [ ] Upload a few files in the portal.
- [ ] Upload a folder with **Storage Explorer** (sign in with your Entra account).
- [ ] Copy a local folder with **AzCopy**:
  ```bash
  azcopy login
  azcopy copy "./sample-files" "https://<account>.blob.core.windows.net/documents" --recursive
  ```
- [ ] Copy the container between the two accounts with AzCopy (account to account).

#### 3.3 Access tiers and lifecycle management
- [ ] Set one blob to **Cool**, one to **Cold**, one to **Archive**.
- [ ] Try to download the Archive blob. It fails. Start **rehydration** to Hot with Standard priority and note it can take up to 15 hours.
- [ ] Create a lifecycle management rule. Skeleton (fill in with Claude Code or the portal code view):
  ```json
  {
    "rules": [
      {
        "name": "tier-documents",
        "enabled": true,
        "type": "Lifecycle",
        "definition": {
          "filters": { "blobTypes": ["blockBlob"], "prefixMatch": ["documents/"] },
          "actions": {
            "baseBlob": {
              "TODO": "cool after 30 days, archive after 90, delete after 365"
            }
          }
        }
      }
    ]
  }
  ```

#### 3.4 Data protection
- [ ] Enable **blob versioning**. Overwrite a file twice and view the versions. Restore an older version.
- [ ] Enable **soft delete for blobs** (7 days) and **for containers** (7 days).
- [ ] Delete a blob and undelete it. Delete a container and restore it.

#### 3.5 Object replication
- [ ] Enable versioning on both accounts and **change feed** on the source.
- [ ] Create a replication policy: source `documents` > destination container on the Central US account.
- [ ] Upload a new file and confirm it appears in the destination.

#### 3.6 Access: keys, SAS, stored access policies
- [ ] Access keys: view key1 and key2. **Rotate key1**. Note the pattern: switch apps to key2, rotate key1, switch back.
- [ ] Generate an **account SAS** (read/list, 1 hour) and test it in a browser against a blob URL.
- [ ] Generate a **service SAS** on a single blob.
- [ ] Generate a **user delegation SAS** (signed with Entra credentials, not the account key) via Storage Explorer or CLI.
- [ ] Create a **stored access policy** on the `documents` container (read, 7 days). Generate a SAS that references it. Then delete the policy and confirm the SAS stops working. That is how you revoke a SAS without rotating keys.

#### 3.7 Identity-based (data plane) access
- [ ] Sign in as jordan and try to read blobs. Fails, even though jordan may see the account.
- [ ] Assign **Storage Blob Data Reader** to jordan on the `documents` container. Retry with the portal set to "Microsoft Entra user account" authentication.
- [ ] Note: **Owner/Contributor are control plane.** Reading data with Entra auth needs a **Storage Blob Data** role.

#### 3.8 Azure Files
- [ ] Create file share `contoso-share` (transaction optimized tier).
- [ ] Start web01 and mount the share using the **Connect** script from the portal (Linux tab). Create a file from the VM and view it in the portal.
- [ ] Take a **share snapshot**. Delete the file. Restore it from the snapshot.
- [ ] Confirm **soft delete for file shares** is on. Delete the share and undelete it.
- [ ] Review Identity-based access settings on the file share (AD DS, Entra Domain Services, Entra Kerberos). You cannot fully lab this without a domain, so write down: identity-based access uses **share-level RBAC roles** (Storage File Data SMB Share Reader/Contributor/Elevated Contributor) plus **NTFS permissions** at the directory/file level.

#### 3.9 Encryption
- [ ] Open Encryption settings. Note Microsoft-managed keys (default) vs customer-managed keys stored in **Key Vault**.
- [ ] Optional: create a Key Vault with purge protection enabled, create a key, and switch the account to customer-managed keys.

#### 3.10 Storage firewall
- [ ] Networking > Public network access: **Enabled from selected virtual networks and IP addresses**. Add your client IP only.
- [ ] Test from your machine (works) and from web01 (fails). Leave it this way; Project 4 fixes it properly with a service endpoint and a private endpoint.

### Break it
- [ ] Put a **ReadOnly lock** on the storage account and try to view access keys. Fails (listing keys is a POST).
- [ ] Use an expired SAS. Read the error.
- [ ] Disable "Allow storage account key access" and try an account SAS. Fails.
- [ ] Turn the firewall to selected networks without adding your IP and try to browse containers in the portal.

### Exam takeaways
- Redundancy: LRS (3 copies, 1 datacenter), ZRS (3 zones), GRS (LRS + async copy to paired region), GZRS (ZRS + paired region). RA- prefix adds read access to the secondary.
- Archive is offline; rehydration is required before reading.
- Lifecycle rules run on days since modification, creation, or last access.
- Object replication requires versioning on both sides and change feed on the source.
- Revoke a SAS by deleting/changing its stored access policy or rotating the key that signed it. User delegation SAS is the most secure SAS type.
- Control plane roles do not grant data access.

### Document it
- [ ] Screenshots: redundancy setting, archive download error, lifecycle rule, version history, replication policy, stored access policy revocation, firewall error, mounted share on the VM.
- [ ] Commit the lifecycle JSON and AzCopy commands.
- [ ] README, break/fix log, exam notes, LinkedIn draft.

### Teardown
- [ ] Keep the data account and file share (Project 4 uses them). Delete the replication account if you want to save cents. Remove any locks.

---

## Project 4: VNets + Private Endpoints + Load Balancing

**Goal:** Contoso's network is segmented into hub and spokes, traffic is filtered, admins reach VMs without public IPs, storage is reachable only privately, and web traffic is load balanced.

**Exam objectives covered:** VNets and subnets; peering; public IPs; user-defined routes; troubleshooting connectivity; NSGs and ASGs; effective security rules; Bastion; service endpoints; private endpoints; Azure DNS; internal or public load balancer; troubleshooting load balancing.

**Time:** 4 to 5 hours, split across the networking sections. **Cost:** a few dollars. **Delete Bastion and the load balancer at the end of each session.**

### Target topology

| VNet | Address space | Subnets |
|---|---|---|
| `vnet-contoso-hub` | 10.0.0.0/16 | `AzureBastionSubnet` 10.0.1.0/26, `snet-shared` 10.0.2.0/24 |
| `vnet-contoso-app` (from Project 2) | 10.1.0.0/16 | `snet-web` 10.1.1.0/24, `snet-data` 10.1.2.0/24, `snet-pe` 10.1.3.0/24 |
| `vnet-contoso-dev` | 10.2.0.0/16 | `snet-dev` 10.2.1.0/24 |

### Steps

#### 4.1 VNets and subnets
- [ ] Create `rg-contoso-network`. Create the hub and dev VNets. Add the new subnets to the app VNet.
- [ ] Note that Azure reserves **5 IPs per subnet** (first 4 and last). A /24 gives 251 usable addresses.
- [ ] Try to add a subnet that overlaps an existing range. Read the error.

#### 4.2 Peering
- [ ] Peer hub <-> app and hub <-> dev. Review the settings: allow traffic, allow forwarded traffic, gateway transit.
- [ ] Deploy a small VM in `snet-dev`. Test from dev VM to web01 (ping or `nc -zv 10.1.1.4 22`). It **fails**: peering is **not transitive**. Screenshot.
- [ ] Fix options to note (do not build): peer dev <-> app directly, or route through an NVA/firewall in the hub with UDRs.

#### 4.3 Public IP
- [ ] Create a Standard SKU, static public IP `pip-contoso-test`. Note: Standard SKU is zone-redundant capable and secure by default (closed until an NSG allows traffic). Basic SKU is retired.
- [ ] Associate it with the dev VM's NIC, then dissociate and delete it after Bastion is working.

#### 4.4 NSGs and application security groups
- [ ] Create ASGs `asg-web` and `asg-data`. Assign web01/web02 NICs to `asg-web`.
- [ ] Create `nsg-contoso-web` and associate it with `snet-web`. Inbound rules:

| Priority | Name | Source | Destination | Port | Action |
|---|---|---|---|---|---|
| 100 | allow-http-vnet | VirtualNetwork | asg-web | 80 | Allow |
| 110 | allow-ssh-bastion | 10.0.1.0/26 | asg-web | 22 | Allow |
| 4000 | deny-all-in | Any | Any | Any | Deny |

- [ ] Open a VM's NIC > **Effective security rules** and see the combined subnet + NIC rules and default rules (65000+).
- [ ] Network Watcher > **IP flow verify**: test TCP 22 from the dev VM IP to web01. Note which rule allowed or denied it.

#### 4.5 Bastion
- [ ] Deploy Bastion into `AzureBastionSubnet` in the hub (subnet must be named exactly that, /26 or larger). Use the **Developer** SKU if your region offers it (free, single connection) or Basic.
- [ ] Connect to web01 through Bastion over SSH. web01 has no public IP.
- [ ] Note: Bastion reaches VMs in peered VNets.

#### 4.6 User-defined routes
- [ ] Create route table `rt-contoso-web`. Route: `0.0.0.0/0` next hop **None**. Associate with `snet-web`.
- [ ] From web01 via Bastion, run `curl -I https://www.microsoft.com`. Fails.
- [ ] Network Watcher > **Next hop** from web01 to 13.107.21.200. Shows the UDR and next hop None.
- [ ] NIC > **Effective routes**: see system routes, peering routes, and your UDR.
- [ ] Remove the association so updates work again.

#### 4.7 Service endpoint
- [ ] Enable the **Microsoft.Storage** service endpoint on `snet-data`.
- [ ] On the storage account firewall, add `vnet-contoso-app/snet-data`.
- [ ] Note: service endpoints keep the storage **public IP** but restrict traffic to the subnet over the Azure backbone.

#### 4.8 Private endpoint + private DNS
- [ ] Storage account > Networking > Private endpoint connections > Create: subresource **blob**, subnet `snet-pe`, integrate with private DNS zone `privatelink.blob.core.windows.net`.
- [ ] Set the storage account public network access to **Disabled**.
- [ ] From web01 via Bastion: `nslookup <account>.blob.core.windows.net`. It resolves to a **10.1.3.x** private IP.
- [ ] From your laptop: browsing the container in the portal now fails. Screenshot.
- [ ] Note: the private DNS zone must be **linked** to every VNet that needs to resolve the name. Link it to the hub too.

#### 4.9 Azure DNS
- [ ] Create a **private DNS zone** `contoso.internal`, link it to the app VNet with **auto-registration** on. Confirm web01 and web02 records appear automatically.
- [ ] Create a **public DNS zone** (for example `contoso-lab-<you>.com`). Add an A record and a CNAME. Note the four name servers you would set at the registrar. If you own a domain (for example your photography site), you can delegate a subdomain to it.

#### 4.10 Internal load balancer
- [ ] Install nginx on web01 and web02 via Run command:
  ```bash
  sudo apt-get update && sudo apt-get install -y nginx && echo "$(hostname)" | sudo tee /var/www/html/index.html
  ```
  (Temporarily remove the UDR from 4.6 if still associated.)
- [ ] Create a **Standard internal load balancer** `lbi-contoso-web`, frontend IP 10.1.1.100 in `snet-web`.
- [ ] Backend pool: web01 and web02. Health probe: HTTP port 80 path `/`. Rule: TCP 80 > 80.
- [ ] From the dev VM: `curl http://10.1.1.100` several times and watch the hostname change.
- [ ] Note: public load balancer is the same build with a public frontend IP.

#### 4.11 Troubleshoot
- [ ] Stop nginx on web01. Check LB > Monitoring > **Health probe status**. Traffic now only goes to web02.
- [ ] Add an NSG rule denying `AzureLoadBalancer` service tag on port 80. Both backends go unhealthy. Remove the rule.
- [ ] Network Watcher > **Connection troubleshoot** from the dev VM to 10.1.1.100 port 80.

### Break it
- [ ] Transitive peering failure (4.2).
- [ ] Overlapping address space.
- [ ] NSG rule priority: add a Deny at priority 90 for port 80 and watch it override the Allow at 100.
- [ ] Private endpoint without a linked DNS zone: unlink it from the app VNet and run nslookup again (resolves public, then fails).
- [ ] Health probe blocked by NSG (4.11).

### Exam takeaways
- NSG rules are processed by **lowest priority number first**; first match wins. Inbound traffic is evaluated by the subnet NSG then the NIC NSG; outbound in the reverse order. Both must allow.
- Default rules allow VNet-to-VNet, allow AzureLoadBalancer inbound, deny all other inbound.
- Peering is non-transitive. Address spaces cannot overlap.
- `AzureBastionSubnet` must be named exactly that and be /26 or larger.
- UDR next hop types: Virtual appliance, Virtual network gateway, Virtual network, Internet, None.
- Service endpoint = public IP, restricted to subnet. Private endpoint = private IP in your VNet plus private DNS.
- Standard load balancer requires an NSG to allow traffic; the health probe source is the `AzureLoadBalancer` service tag (168.63.129.16).

### Document it
- [ ] Architecture diagram of the full hub-and-spoke (this is the headline image for LinkedIn).
- [ ] Screenshots: transitive peering failure, effective security rules, IP flow verify, next hop None, private IP nslookup, LB alternating hostnames, unhealthy probe.
- [ ] Commit a Bicep or CLI script that rebuilds the network so you can tear down and redeploy cheaply.
- [ ] README, break/fix log, exam notes, LinkedIn draft.

### Teardown (every session)
- [ ] Delete Bastion and the load balancer. Deallocate VMs. Keep VNets, NSGs, DNS zones, and the private endpoint (they cost little or nothing; check your cost analysis).

---

## Project 5: Monitor + Log Analytics + Backup + Site Recovery

**Goal:** Contoso sees what is happening, gets alerted when something breaks, and can recover VMs and data, including in another region.

**Exam objectives covered:** Metrics; log settings; KQL queries; alert rules, action groups, alert processing rules; Insights for VMs, storage, networks; Network Watcher and Connection Monitor; Recovery Services vault; Backup vault; backup policy; backup and restore; Site Recovery configuration and failover; backup reports and alerts.

**Time:** 3 to 4 hours. **Cost:** a few dollars. **Site Recovery replication bills while it runs; clean it up the same day.**

### Steps

#### 5.1 Log Analytics and diagnostic settings
- [ ] Create `rg-contoso-monitor` and Log Analytics workspace `law-contoso`. Set daily cap to 0.5 GB to control cost.
- [ ] **Activity log:** Monitor > Activity log > Export activity logs > send to `law-contoso`.
- [ ] **Storage account:** Diagnostic settings on the blob service > StorageRead, StorageWrite, StorageDelete > `law-contoso`.
- [ ] **NSG/VNet flow logs:** Network Watcher > Flow logs > create a VNet flow log for the app VNet, with traffic analytics to `law-contoso`.

#### 5.2 VM insights
- [ ] Start web01 and web02. Monitor > Insights > Virtual machines > enable. This installs the **Azure Monitor Agent** and creates a **data collection rule** pointing to `law-contoso`.
- [ ] Review Performance and Map views.

#### 5.3 Metrics
- [ ] Metrics explorer: chart **Percentage CPU** for both VMs, split by instance. Pin to a new dashboard `dash-contoso`.
- [ ] Add the storage account **Transactions** metric split by API name to the same dashboard.

#### 5.4 KQL queries
Run these in `law-contoso` and save each one:

```kusto
// Who deleted or created resources in the last 24h
AzureActivity
| where TimeGenerated > ago(24h)
| where OperationNameValue has_any ("delete", "write")
| project TimeGenerated, Caller, OperationNameValue, ResourceGroup, ActivityStatusValue

// Average CPU per VM in 5-minute bins
InsightsMetrics
| where Namespace == "Processor" and Name == "UtilizationPercentage"
| summarize avg(Val) by bin(TimeGenerated, 5m), Computer
| render timechart

// Heartbeat gaps (VM possibly down)
Heartbeat
| summarize LastHeartbeat = max(TimeGenerated) by Computer
| where LastHeartbeat < ago(10m)

// Storage operations by type
StorageBlobLogs
| summarize count() by OperationName, StatusText
```

#### 5.5 Alerts
- [ ] Create action group `ag-contoso-ops`: email + push to the Azure mobile app.
- [ ] **Metric alert:** CPU > 80% for 5 minutes on web01 > `ag-contoso-ops`.
- [ ] **Log alert:** using the heartbeat query, fire when any result is returned.
- [ ] **Activity log alert:** operation "Delete Virtual Machine" on the subscription.
- [ ] Trigger the CPU alert: via Run command run `stress-ng --cpu 2 --timeout 600` (install with apt first). Confirm the email.
- [ ] Create an **alert processing rule** that suppresses notifications for `rg-contoso-compute` during a scheduled window (for example tonight 10 PM to 11 PM). Note: processing rules modify or suppress actions; they do not stop the alert from firing.

#### 5.6 Network monitoring
- [ ] Monitor > Insights > **Networks**: review health of the VNets, load balancer, and private endpoint.
- [ ] Network Watcher > **Connection Monitor**: test group from dev VM to web01 port 80 and to the storage private endpoint port 443. Review results after 10 minutes.
- [ ] Monitor > Insights > **Storage accounts**: review availability and latency.

#### 5.7 Backup with Recovery Services vault
- [ ] Create `rsv-contoso` in East US 2 (in `rg-contoso-monitor`). Note the vault redundancy setting (GRS default) can only be changed **before** protecting items.
- [ ] Create backup policy `pol-vm-daily`: daily at 11 PM, retain daily for 7 days, weekly for 4 weeks.
- [ ] Enable backup on web01 with that policy. Run **Backup now**.
- [ ] After it completes: **File Recovery** (mount the recovery point via script and copy a file out), then **Restore VM** as a new VM `vm-contoso-web01-restored`. Delete the restored VM afterward.
- [ ] Back up the Azure file share `contoso-share` with the vault too.
- [ ] Stop backup on web01 with "Delete backup data". Observe **soft delete** keeps it for 14 days. Undelete it, then stop again.

#### 5.8 Backup vault
- [ ] Create a **Backup vault** `bv-contoso`. Configure **operational backup for blobs** on the storage account (requires the vault's managed identity to have Storage Account Backup Contributor on the account).
- [ ] Write in exam notes which workloads go to which vault: Recovery Services vault (VMs, Azure Files, SQL/SAP in VMs) vs Backup vault (blobs, managed disks, PostgreSQL, AKS).

#### 5.9 Site Recovery
- [ ] Create a Recovery Services vault `rsv-contoso-dr` in **Central US** (target region).
- [ ] On web02: Disaster recovery > target region Central US > let it create target resources. Wait for replication health to be healthy (can take an hour).
- [ ] Run **Test failover** to an isolated test VNet. Confirm the VM boots in Central US. Then **Cleanup test failover**.
- [ ] Read through planned failover, commit, and re-protect steps. Optional: run a real failover and failback if credit allows.
- [ ] Disable replication when done (stops billing).

#### 5.10 Backup reports and alerts
- [ ] Configure diagnostic settings on `rsv-contoso` to send to `law-contoso` (resource-specific tables).
- [ ] Open Backup center > **Backup reports** and select the workspace. Data may take up to 24 hours.
- [ ] Review Backup center > **Alerts**. Built-in Azure Monitor alerts fire for failed jobs.

### Break it
- [ ] Stop a VM and watch the heartbeat log alert fire.
- [ ] Try changing vault redundancy after protecting an item.
- [ ] Try deleting `rsv-contoso` while it still has protected items (soft-deleted items count too).
- [ ] Remove the RBAC role from the Backup vault identity and retry blob backup configuration.

### Exam takeaways
- Metrics are numeric, near real-time, kept 93 days. Logs go to a Log Analytics workspace and are queried with KQL.
- Diagnostic settings route platform logs; the Azure Monitor Agent + DCR collect guest OS data.
- Alert flow: alert rule > action group (who/what) > alert processing rule (suppress/modify at scale).
- Recovery Services vault: VMs, Azure Files. Backup vault: blobs, disks, and newer workloads.
- Vault storage redundancy is locked after the first protected item.
- Site Recovery: replicate > test failover > failover > commit > re-protect > failback.

### Document it
- [ ] Screenshots: dashboard, saved KQL results, alert email, processing rule, Connection Monitor, file recovery, test failover VM in Central US, backup report.
- [ ] Commit the KQL queries as `.kql` files.
- [ ] README, break/fix log, exam notes, LinkedIn draft.

### Teardown
- [ ] Disable Site Recovery replication and delete `rsv-contoso-dr` contents.
- [ ] Stop VM backup, delete backup data, and disable soft delete only if you need to delete the vault now.
- [ ] Lower or remove the Log Analytics daily cap after you finish with reports.

---

## Bonus: App Service + Containers

**Exam objectives covered:** App Service plan, scaling, create app, TLS/certificates, custom DNS, backup, networking, deployment slots; Azure Container Registry, Container Instances, Container Apps, sizing and scaling.

**Time:** 2 hours. **Cost:** delete the same day.

### App Service
- [ ] Create App Service plan `asp-contoso` on **Standard S1** (slots and autoscale need Standard or higher).
- [ ] Create web app `app-contoso-<you>` (Linux, Node or .NET). Deploy the sample.
- [ ] Settings: HTTPS only on, minimum TLS 1.2, view TLS/SSL certificate options (App Service managed certificate needs a custom domain).
- [ ] Custom domain: if you have a domain, add CNAME + TXT verification records and bind a managed certificate.
- [ ] Scaling: scale up to S2 and back; add a scale-out rule (CPU > 70%, max 3).
- [ ] Create a **staging slot**, change a setting there, and **swap** with production. Note which settings are slot-specific (deployment slot setting checkbox).
- [ ] Configure **backup** to the storage account (note the private endpoint may block it; that is a useful break/fix entry).
- [ ] Networking: enable **VNet integration** into a new subnet in the app VNet, and add an **access restriction** allowing only your IP.

### Containers
- [ ] Create **Azure Container Registry** `acrcontoso<you>` (Basic).
- [ ] Build and push without local Docker:
  ```bash
  az acr build --registry acrcontoso<you> --image hello:v1 <path-to-Dockerfile-folder>
  ```
- [ ] **Container Instances:** deploy `hello:v1` with 1 vCPU, 1.5 GB, public DNS label. Note ACI has no autoscale; you scale by changing CPU/memory or running more container groups.
- [ ] **Container Apps:** deploy the same image to a Container Apps environment with an HTTP scale rule, min replicas 0, max 5. Hit the URL and watch replicas scale.

### Teardown
- [ ] Delete the App Service plan, web app, ACR, ACI, and Container Apps environment.

---

## Final capstone

- [ ] Draw the full architecture (draw.io or Excalidraw): identity, governance hierarchy, hub-and-spoke network, storage with private endpoint, monitoring, backup, and DR region.
- [ ] Update the root `README.md`: overview, diagram, project links, skills list, and the AZ-104 badge once you pass.
- [ ] Post a final LinkedIn summary linking the repo.
- [ ] Add the strongest two or three resume bullets.
- [ ] Load `docs/exam-notes.md` and the break/fix logs into NotebookLM for final review.
- [ ] Take the [free Microsoft practice assessment](https://learn.microsoft.com/en-us/credentials/certifications/exams/az-104/practice/assessment?assessment-type=practice&assessmentId=21) and Scott Duffy's practice tests. Book the exam at a consistent 80%+.
- [ ] Final teardown: delete all `rg-contoso-*` resource groups. Keep the repo.

---

## Exam objective coverage matrix

| Exam objective group | Project |
|---|---|
| Entra users and groups, licenses, external users, SSPR | 1 |
| Built-in roles, scopes, interpreting access | 2 (+3 data roles) |
| Policy, locks, tags, resource groups, subscriptions, costs, management groups | 2 |
| Storage firewalls, SAS, stored access policies, keys, Azure Files identity access | 3 (+4) |
| Storage accounts, redundancy, object replication, encryption, Storage Explorer, AzCopy | 3 |
| File shares, containers, tiers, soft delete, snapshots, lifecycle, versioning | 3 |
| ARM templates and Bicep | 2 |
| VMs: create, encryption at host, move, size, disks, zones/sets, scale sets | 2 |
| Containers: ACR, ACI, Container Apps | Bonus |
| App Service | Bonus |
| VNets, subnets, peering, public IPs, UDRs, connectivity troubleshooting | 4 |
| NSGs, ASGs, effective rules, Bastion, service and private endpoints | 4 |
| Azure DNS, load balancers, load balancer troubleshooting | 4 |
| Azure Monitor metrics, logs, KQL, alerts, Insights, Network Watcher | 5 (+4) |
| Recovery Services vault, Backup vault, policies, restore, Site Recovery, reports | 5 |
