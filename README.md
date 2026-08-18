# ❄️ sinnoh

Declarative infrastructure for a small NixOS fleet and its Kubernetes workloads. The repository uses a flake-parts Nix flake for host configuration, k3s for the cluster, Flux for GitOps reconciliation, and SOPS with age recipients for secrets.

## Architecture

| Host                                                 | Platform           | Role                                     |
| ---------------------------------------------------- | ------------------ | ---------------------------------------- |
| [`sunnyshore`](nix/hosts/nixos/sunnyshore/README.md) | NixOS on OpenStack | k3s server and control-plane data backup |
| [`canalave`](nix/hosts/nixos/canalave/README.md)     | NixOS on OpenStack | k3s agent and observability services     |

The nodes communicate over the `sinnoh` WireGuard interface. Flux watches the `master` branch and reconciles `k8s/flux-system`, which composes the application, networking, certificate, database, backup, and secret resources in the cluster.

## Repository Layout

```text
.
├── flake.nix                 Flake inputs and top-level composition
├── nix/
│   ├── hosts/nixos/         Per-host composition, disks, and hardware facts
│   ├── nixos/               Shared services, programs, users, and features
│   ├── deployments.nix      blzrd deployment targets
│   ├── devShells.nix        Development tools
│   └── treefmt.nix          Formatting and linting configuration
├── k8s/
│   ├── flux-system/         Flux bootstrap and reconciliation graph
│   ├── charts/              Local Helm charts
│   └── <service>/           Kustomize and Helm release resources
├── keys/                    Public SSH keys used as age recipients
├── secrets/                 SOPS-encrypted host and Kubernetes secrets
├── scripts/                 Repository maintenance scripts
└── .github/workflows/       Flake checks and host builds
```

Nix files are imported recursively, so new modules should declare or extend a flake output rather than being added to a central import list.

## Development

Install Nix with flakes enabled, then enter the pinned shell:

```bash
nix develop
```

The shell provides Bun, Just, SOPS, `ssh-to-age`, and `blzrd`. With direnv installed, `direnv allow` enters the same environment automatically. Run `just` to list the available maintenance recipes.

Before committing a change, format and validate the complete flake:

```bash
nix fmt
nix flake check
```

`nix flake check` runs the treefmt and deployment-node checks. CI also builds both NixOS configurations. Build an affected host locally without activating it:

```bash
nix build .#nixosConfigurations.sunnyshore.config.system.build.toplevel
nix build .#nixosConfigurations.canalave.config.system.build.toplevel
```

## Deployment

The flake exposes both hosts as `blzrd` nodes. Deploy one host after a successful build:

```bash
blzrd switch sunnyshore
```

Running `blzrd switch` without a node deploys the complete fleet. These commands activate live system configurations, so review the evaluated changes before running them.

Kubernetes resources follow a GitOps workflow: changes merged to `master` are reconciled by Flux. Application definitions belong in `k8s/<service>/`; reusable local charts belong in `k8s/charts/<service>/`. Do not hand-edit the generated `k8s/flux-system/gotk-components.yaml` manifest.

## Secrets

Only encrypted secret files and public keys may be committed. Bootstrap local age access once, then edit a secret through SOPS:

```bash
just sops-bootstrap
just sops-edit tailscale.yaml
just sops-edit kubernetes/pocket-id-env.sops.yaml
```

When adding or removing a public key in `keys/`, regenerate the SOPS configuration and re-encrypt every managed secret:

```bash
just sops-rekey
```

Commit `.sops.yaml` and all resulting encrypted-file updates together. Never commit decrypted output, private keys, or credentials.

## Contributing

See [AGENTS.md](AGENTS.md) for repository conventions, validation expectations, and pull request guidance. This project is available under the [MIT License](LICENSE.md).
