<!-- Auto-generated guidance for AI coding agents working on this repository -->
# Copilot instructions — jpd-project

Purpose: quickly orient an AI coding agent to the project's structure, common workflows, and the few non-obvious commands and files humans expect to find.

- Repo top-level: major areas are `jpd-dev`, `jpd-manage`, `jpd-ops`, `jpd-sec` and language demos (see below).

Where to start (high-level):
- `jpd-dev`: developer/demo apps (Java, Node, Python, Go, Swift, Cargo examples).
- `jpd-manage`: management-side tools and docs ([jpd-manage README](jpd-manage/README.md)).
- `jpd-ops`: operational tooling, Helm charts and health-check scripts ([jpd-ops README](jpd-ops/README.md)).
- `jpd-sec`: security automation and Frogbot integration ([frogbot Jenkinsfile](jpd-sec/frogbot/jenkins/Jenkinsfile-Github)).

Quick actionable workflows (concrete examples found in this repo):
- Run the Artifactory health-check tool (Python):
  - Create venv: `/opt/homebrew/bin/python3.13 -m venv venv`
  - Activate: `source venv/bin/activate`
  - Install: `pip install -r jpd-ops/health-check/requirements.txt`
  - Run: `python jpd-ops/health-check/artifactory-analysis.py <support-bundle.zip>`
  (See [jpd-ops/health-check/README.md](jpd-ops/health-check/README.md) for details.)
- Run Frogbot scan (CI/cron job uses this): change into the backend folder and run the downloaded `frogbot` executable:
  - Example from Jenkinsfile: `cd jpd-dev/npm/app-npm/backend && ./frogbot scan-repository` ([Jenkinsfile-Github](jpd-sec/frogbot/jenkins/Jenkinsfile-Github)).

Build/test heuristics & common locations:
- Java/Maven apps: look under `jpd-dev/*/app-*-boot` and `connect/*` subfolders for `pom.xml` (IDE project references exist in `.idea`). Use `mvn -DskipTests package` as the safe build.
- Node/npm apps: check `jpd-dev/npm/app-npm` and its `backend` subfolder for CI hooks (Frogbot downloads/runs there).
- Python scripts & tools: see `jpd-ops/health-check` and `jpd-sec/*` for scripts and `requirements.txt` usage.
- Helm charts & one-click install: `jpd-ops/install/jfrog-helm-install/one-click/helm/artifactory` (values and sizing references live here).

Project-specific conventions and patterns:
- Several components are example/demo applications — changes should preserve the example intent.
- CI/automation favors environment-driven behavior: `JF_*` env vars are used heavily by Frogbot/Jenkins pipelines ([see Jenkinsfile](jpd-sec/frogbot/jenkins/Jenkinsfile-Github)).
- If a subproject uses a wrapper (Gradle/Maven/Poetry), prefer the wrapper when present (Jenkinsfile shows `JF_USE_WRAPPER` usage).
- The `ai-editor-extension` folder contains instructions for product.json and IDE extension caching — useful for editor-related automation ([jpd-dev/ai-editor-extension/README.md](jpd-dev/ai-editor-extension/README.md)).

Where to look for examples and integrations:
- Frogbot + Jenkins: `jpd-sec/frogbot/jenkins/Jenkinsfile-Github` — shows download, env var configuration, and the exact scan command.
- Health-check script: `jpd-ops/health-check/artifactory-analysis.py` + README — contains the precise Python version used and dependency list.
- Helm charts and values: `jpd-ops/install/jfrog-helm-install/one-click/helm/artifactory`.

What NOT to assume:
- There is no single top-level build/test command for the whole monorepo — treat each module by its language and local README.
- Do not attempt deployment without confirming environment variables in Jenkinsfile or Helm values in `jpd-ops`.

If you make code changes:
- Prefer small, focused edits and point to the exact example file you changed in your commit message.
- When adding automation (CI scripts, wrappers), update the related README under the same subfolder.

If anything above is unclear or you need more examples (e.g., exact `pom.xml` locations, package.json scripts, or sample env var values), tell me which component you want prioritized and I'll expand the instructions.
