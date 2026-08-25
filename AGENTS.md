# Work in Sinnoh

Sinnoh runs production infrastructure. `nix/hosts/nixos/` contains the Sunnyshore and Canalave hosts. `k8s/` contains Flux-managed workloads. `terraform/` manages Cloudflare DNS. Keep secrets in `secrets/` and public SOPS recipients in `keys/`.

## Check a change

Run `nix fmt` and `nix flake check` before you commit. Build the changed host. Build both hosts when you change a shared NixOS module.

```sh
nix build .#nixosConfigurations.sunnyshore.config.system.build.toplevel
nix build .#nixosConfigurations.canalave.config.system.build.toplevel
```

If a NixOS host's `facter.json` changes, run `nix run github:alyraffauf/infra#generate-host-readmes`. Do not edit text between generated-section markers in a host README.

When you change a Kubernetes resource, update its `kustomization.yaml` or Flux resource in the same change. Do not reformat `k8s/flux-system/gotk-components.yaml`.

For Terraform changes, run these commands after direnv loads the credentials:

```sh
tofu -chdir=terraform fmt -check
tofu -chdir=terraform plan
```

## Deploy deliberately

Flux deploys Kubernetes changes from `master`. Do not apply repository manifests with `kubectl` unless you are recovering the cluster. Use `blzrd switch sunnyshore` or `blzrd switch canalave` only after validation. `blzrd boot <host>` changes the next boot without activating it. A bare `blzrd switch` targets both hosts.

The B2 state backend does not lock OpenTofu state. Review the plan before you apply, and never run concurrent applies.

## Keep secrets out of Git

Do not commit decrypted secrets, private keys, OpenTofu state, or saved plans. Edit secrets through SOPS. When `keys/` changes, run `just sops-rekey` and commit the updated `.sops.yaml` and encrypted files together.
