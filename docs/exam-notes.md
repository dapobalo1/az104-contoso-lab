# AZ-104 Exam Notes

Three to five lines per project. Format: `- [P#] takeaway`. Feed this file into NotebookLM before the exam.

## Project 1: Entra ID + Conditional Access
- [P1] A tenant holds identities; a subscription holds resources and trusts exactly one tenant. RBAC can only be assigned to identities in that tenant.
- [P1] Moving a subscription to another tenant (Change directory) can be blocked by the source tenant's subscription policies. Moving it removes existing RBAC role assignments.
- [P1] `#EXT#` in a UPN means the identity comes from another directory. User type (Member or Guest) is a separate property that controls default permissions.
- [P1] Deleted users are soft-deleted for 30 days. Their UPN stays reserved until restored or permanently deleted.
- [P1] Directory roles can be assigned from the user (Assigned roles) or from the role (Roles and administrators > Add assignments).
- [P1] New tenants have security defaults on: free, all-or-nothing MFA baseline. They must be turned off before Conditional Access policies can be used.

- [P1] Users can be created in the Entra admin center, Azure portal, M365 admin center, CLI/PowerShell, or bulk CSV. All write to the same Entra ID directory.
- [P1] Usage location (licensing country) is not Office location (free text). License assignment fails without usage location.
- [P1] Bulk create takes a downloaded CSV template; do not edit the header row. Results show under Bulk operation results.
- [P1] `az ad user create` sets name, UPN, and password only. Department, job title, and usage location are set afterwards (portal or `az ad user update`).
- [P1] Dynamic groups need Entra ID P1+. Rule syntax: (user.department -eq "Finance"). Members are added by the rule only, not by hand, and evaluation takes a few minutes.
- [P1] Group owners manage membership without an admin role. Owner and member are separate: an owner is not automatically a member.
- [P1] Security group = access control. Microsoft 365 group = shared mailbox, calendar, SharePoint site, and Teams.
- [P1] Group-based licensing (P1+): members of the group inherit the license; removing them from the group removes it. An inherited license cannot be removed on the user's page, only by changing group membership.
- [P1] A user's usage location cannot be cleared while a license is assigned.
- [P1] Guest invites (B2B): UPN gets `#EXT#`, User type = Guest, Invitation state Pending acceptance until redeemed. User type can be switched Guest <-> Member on the user's properties.
- [P1] External collaboration settings control who can invite guests and how much of the directory guests can see (3 restriction levels; default is limited access).
- [P1] SSPR scope: None, Selected (one group only), or All. Admins always get SSPR with a two-method policy regardless of these settings. Reconfirm interval is 0 to 730 days (0 = never).
- [P1] SSPR and MFA methods are managed together in the Authentication methods policy. SSPR fails with "not properly set up" if a user has fewer usable methods than the number required.
- [P1] Entra roles control the directory (users, groups, licenses, passwords). Azure RBAC roles control Azure resources. Separate systems.
- [P1] Helpdesk Administrator can reset passwords for non-admins and some limited admins, never for Global Administrators or other privileged roles.

## Project 2: VMs + RBAC + Policy + Budgets + Bicep

## Project 3: Storage + Access Tiers

## Project 4: VNets + Private Endpoints + Load Balancing

## Project 5: Monitor + Log Analytics + Backup + Site Recovery

## Bonus: App Service + Containers
- [P1] Security defaults and Conditional Access cannot run together; turn security defaults off first. CA needs Entra ID P1 or higher.
- [P1] Named locations: Countries/regions (country derived from the sign-in IP) or IP ranges (CIDR, can be marked trusted).
- [P1] What If evaluates policies in every state (On, Report-only, Off). The "Reasons why this policy will not apply" column (Users and groups, Location, Client app) is the troubleshooting answer for "why wasn't I prompted for MFA?"
- [P1] Block legacy authentication: target Exchange ActiveSync and Other clients, because legacy protocols cannot do MFA.
- [P1] Always exclude a break-glass account from every CA policy; roll out new policies in Report-only first.
- [P1] One sign-in writes several log rows. Codes: 50126 bad password (CA Not Applied, it runs after primary auth), 50072 must register MFA, 50074 strong auth required, 50140 "Stay signed in?" interrupt, 53003 blocked by Conditional Access, 0 success.
- [P1] Sign-in log Conditional Access tab shows what actually happened; the Report-only tab shows what Report-only policies would have done. What If only predicts.
- [P1] Dynamic group troubleshooting: Dynamic membership rules > Validate Rules tests chosen users against the rule instantly and shows the actual attribute value. Overview shows processing status and last membership change. `-eq` is case-insensitive. You cannot add members manually to a dynamic group.
