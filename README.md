# Project: eu-peptides.org Webshop

## 1. Project Goal

The primary objective is to create a fully functional, secure, and performant e-commerce webshop on the domain `eu-peptides.org`.

* **Primary Design Template:** `uk-peptides.com` (for general layout).
* **Primary Structural Template:** `particlepeptides.com` (for product categories and informational pages).
* **Custom Aesthetics:** Bordeaux red (`#800020`) and black color scheme.
* **Key Features:** Functional Peptide Calculator, Affiliate Program, Newsletter System, and standard e-commerce pages.
* **Core Mandate:** Maximum automation for setup and a professional, version-controlled workflow.

## 2. Collaboration Protocol

**This `README.md` file is the central source of truth for the project.** All collaborating AI instances (Gemini, Jules, Codex, etc.) must first read this file to understand the current project status and objectives. Any action that alters the project's state or core scripts must result in an update to this file to ensure all collaborators remain synchronized.

## 3. Current Project Status

* **Infrastructure:** A Google Cloud Platform (`e2-micro`, 30GB disk) VM is provisioned with a static IP address.
* **Operating System:** Ubuntu 22.04 LTS.
* **Connectivity:** Passwordless SSH key access is configured from the primary stakeholder's Mac (`cosmopaxhaven-5`). A permanent SSH alias, `peptides-server`, is configured in the local `~/.ssh/config` file for convenient access.
* **Automation:** A single, idempotent `master_setup.sh` script has been developed. This script handles all server setup, WordPress installation, site structure generation, plugin installation, and SSL configuration. **The script has not yet been successfully run to completion.**

## 4. Immediate Action Plan

1.  **Commit Project Files:** The `README.md` and `master_setup.sh` files should be committed to the `main` branch of this GitHub repository.
2.  **Deploy to Server:** The repository should be cloned to the server.
3.  **Execute Master Script:** The `master_setup.sh` script must be run on the server to build the site.

## 5. The Master Setup Script (`master_setup.sh`)

The contents of the final, corrected master setup script are maintained in the `master_setup.sh` file within this repository.

