# Project: eu-peptides.org Webshop
- **Last Updated:** 2025-06-25
- **Current Status:** Ready for Automated Deployment

## 1. Project Mandate & Guiding Principles
The primary objective is to create a fully functional, secure, and performant e-commerce webshop on the domain `eu-peptides.org`.

### Collaboration Protocol
**This `README.md` file is the central source of truth for the project.** All collaborating AI instances (Gemini, Jules, Codex, etc.) must first read this file to understand the current project status and objectives. Any action that alters the project's state or core scripts must result in an update to this file (via a new Git commit) to ensure all collaborators remain synchronized and work towards the final goal.

### Project Specifications
- **Primary Design Template:** `uk-peptides.com` (for general layout).
- **Primary Structural Template:** `particlepeptides.com` (for product categories and informational pages).
- **Custom Aesthetics:** Bordeaux red (`#800020`) and black color scheme.
- **Key Features:** Functional Peptide Calculator, Affiliate Program, Newsletter System.

---

## 2. Project Status Log

### Phase 1: Infrastructure Setup (COMPLETE)
- A Google Cloud Platform (`e2-micro`, 30GB disk) VM was provisioned.
- A static IP address was assigned and configured.
- DNS `A` record for `eu-peptides.org` points to the static IP via Cloudflare.
- Passwordless SSH key access was configured. A permanent SSH alias, `peptides-server`, is active on the primary stakeholder's Mac (`cosmopaxhaven-5`).

### Phase 2: Troubleshooting & Script Development (COMPLETE)
- Encountered and resolved numerous critical server and software issues:
  - `sudo` privileges were missing for the default user and have been granted.
  - SSH public key authentication failures were resolved.
  - Fatal errors within WooCommerce (`LookupDataStore.php`) were diagnosed.
  - In-memory `nano` editing proved unreliable; workflow switched to `cat <<'EOF'` for script creation.
  - Automated web scraping proved fragile; workflow switched to hardcoded, reliable script logic.
- **Outcome:** The result of this phase is the creation of the definitive `master_setup.sh` script. This script is idempotent and represents the complete, tested blueprint for the website.

---

## 3. Current Action Plan

### **CURRENT TASK: Initial Site Deployment**
- **Status:** **Pending Execution.**
- **Assignee:** Patrick (cosmopax).
- **Objective:** Run the `master_setup.sh` script on the clean server to build the entire site structure, install plugins, and configure the system in one automated pass.
- **Execution Steps:**
  1. `git push` local project files (`README.md`, `master_setup.sh`) to the GitHub remote repository.
  2. `ssh peptides-server` to connect to the production server.
  3. `git clone` the repository onto the server.
  4. `sudo ./master_setup.sh` to execute the deployment.

### POST-DEPLOYMENT (PHASE 3)
- Configure installed plugins (Stripe, AffiliateWP, WP Mail SMTP, etc.).
- Populate site with original content, replacing all placeholders.
- Implement the Peptide Calculator functionality.

