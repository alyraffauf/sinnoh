# Repository Guidelines

## Project Structure & Module Organization

This repository manages the `canalave` and `sunnyshore` NixOS hosts plus their Flux-managed Kubernetes workloads. `flake.nix` imports the flake-parts modules under `nix/`. Put reusable system settings in `nix/nixos/`, host composition and hardware state in `nix/hosts/nixos/<hostname>/`, and shared flake concerns such as deployments, overlays, development shells, and formatting directly in `nix/`. Kubernetes applications use `k8s/<service>/` for Flux/Kustomize resources and `k8s/charts/<service>/` for local Helm charts. Public recipients belong in `keys/`; only SOPS-encrypted data belongs in `secrets/`.

## Build, Test, and Development Commands

Run commands from the repository root:

- `nix develop` enters the pinned development shell with Bun, Just, SOPS, and repository tools.
- `nix fmt` applies treefmt formatting and lint fixes across supported files.
- `nix flake check` evaluates the flake and runs all configured checks; this is the baseline pre-commit test.
- `nix build .#nixosConfigurations.sunnyshore.config.system.build.toplevel` builds a host without deploying it; replace `sunnyshore` with `canalave` as needed.
- `just` lists maintenance recipes. For example, `just update-nixpkgs` updates pinned inputs.

## Coding Style & Naming Conventions

Use two-space indentation in Nix and YAML. Let Alejandra determine Nix layout, and keep modules small and focused on one service or feature. Use lowercase, hyphenated filenames such as `auto-upgrade.nix`; match existing camelCase Nix attributes where required. Treefmt enables Alejandra, deadnix, statix, Prettier, ShellCheck, and shfmt. Do not manually reformat generated `k8s/flux-system/gotk-components.yaml`.

## Testing Guidelines

There is no unit-test suite or coverage target. Always run `nix flake check`, then build every affected host. Changes under shared `nix/nixos/` modules should build for both hosts. Do not deploy or run `nixos-rebuild switch` merely for validation.

## Secrets & Configuration Safety

Never commit plaintext secrets, decrypted output, or private keys. Use `just sops-edit <file>.yaml` for top-level secrets. After changing recipients in `keys/`, run `just sops-rekey` and commit `.sops.yaml` with all re-encrypted files.

## Commit & Pull Request Guidelines

Follow the recent Conventional Commit pattern: `feat(vaultwarden): run on PostgreSQL`, `fix(identity): reconcile chart revisions`, or `ci: build NixOS hosts`. Keep commits focused. Pull requests should name affected hosts or services, explain deployment or migration impact, link relevant issues, and list exact checks and builds run. Include screenshots only for user-visible changes.
