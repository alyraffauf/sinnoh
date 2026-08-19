# Repository Guidelines

## Project Structure & Module Organization

`flake.nix` imports the flake-parts modules under `nix/`. Shared NixOS settings live in `nix/nixos/`; host composition and hardware state for `sunnyshore` and `canalave` live in `nix/hosts/nixos/<host>/`. Kubernetes workloads are grouped by service in `k8s/<service>/`, reusable charts are under `k8s/charts/`, and Flux resources are under `k8s/flux-system/`. OpenTofu configuration is in `terraform/`, encrypted configuration in `secrets/`, public keys in `keys/`, and utilities in `scripts/`.

## Build, Test, and Development Commands

- `nix develop` enters the pinned development shell with Bun, Just, OpenTofu, SOPS, `blzrd`, and repository tooling. Direnv users can run `direnv allow` to load the shell and decrypt OpenTofu credentials.
- `nix fmt` runs treefmt across Nix, YAML/JSON/Markdown, TypeScript, and shell files.
- `nix flake check` evaluates the complete flake and runs configured checks; this is the primary test command.
- `nix build .#nixosConfigurations.sunnyshore.config.system.build.toplevel` builds one host without activating it. Replace `sunnyshore` with `canalave` as needed.
- `bun scripts/generate-host-readmes.ts` refreshes the generated hardware section in every host README from its `facter.json`; do not hand-edit those sections.
- `tofu -chdir=terraform plan` previews Cloudflare DNS changes after direnv loads the Cloudflare and Backblaze credentials.
- `just` lists maintenance recipes, including `just sops-edit tailscale.yaml` for encrypted secrets.

Run formatting and `nix flake check` before submitting changes. For host-specific work, also build the affected host output.

## Deployments

`nix/deployments.nix` registers `sunnyshore` and `canalave` as `blzrd` nodes. After validation, run `blzrd switch sunnyshore` or `blzrd switch canalave` to activate a host and set its boot default. Use `blzrd boot <host>` to set the boot default without activating it. Bare `blzrd switch` targets both nodes; reserve it for deliberate fleet-wide deployments. Do not deploy merely to validate a change.

## Coding Style & Naming Conventions

Let `nix fmt` define formatting through Alejandra, deadnix, statix, Prettier, shfmt, and ShellCheck. Use two-space indentation in Nix and YAML. Prefer composable modules and kebab-case filenames such as `prometheus-node.nix`. Keep Kubernetes resource names aligned with their workload and `kustomization.yaml` entries. Do not manually reformat generated `k8s/flux-system/gotk-components.yaml`.

## Testing Guidelines

There is no separate unit-test framework or coverage threshold. Treat successful flake evaluation and affected-output builds as required validation. Changes under shared `nix/nixos/` modules should build for both hosts. When editing Kubernetes manifests, verify that every added or renamed resource is referenced by the relevant Kustomize and Flux definitions. For OpenTofu changes, run `tofu -chdir=terraform fmt -check` and review `tofu -chdir=terraform plan`; do not apply changes merely to validate them.

## Commit & Pull Request Guidelines

History follows Conventional Commit-style subjects such as `feat(scope): ...`, `fix(scope): ...`, `chore(scope): ...`, and `ci: ...`. Use an imperative, concise subject and a scope such as `identity`, `tranquil-pds`, or `terraform` when useful. Pull requests should explain operational impact, identify affected hosts or services, link related issues when applicable, and list commands run. Call out migrations, restarts, and rollback concerns explicitly.

## Security & Configuration

Never commit decrypted secrets, private keys, OpenTofu state, or saved plans. Edit encrypted files through SOPS. After changing recipients in `keys/`, run `just sops-rekey` and review `.sops.yaml` and every re-encrypted file before committing.
