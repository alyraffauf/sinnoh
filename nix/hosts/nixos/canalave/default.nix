{
  inputs,
  self,
  ...
}: {
  config = {
    flake.nixosConfigurations.canalave = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [
        inputs.determinate.nixosModules.default
        inputs.disko.nixosModules.disko
        inputs.sops-nix.nixosModules.sops
        self.nixosModules.autoUpgrade
        self.nixosModules.default
        self.nixosModules.canalave
        self.nixosModules.aly
        self.nixosModules.alloy
        self.nixosModules.backups
        self.nixosModules.comin
        self.nixosModules.k3s
        self.nixosModules.prometheusNode
        self.nixosModules.tailscale
        self.nixosModules.wireguardSinnoh
      ];

      specialArgs = {inherit self;};
    };

    blzrd.nodes.canalave = {
      output = self.nixosConfigurations.canalave.config.system.build.toplevel;
      type = "nixos";
      user = "root";
    };
  };
}
