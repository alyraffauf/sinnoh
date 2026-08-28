{
  inputs,
  self,
  ...
}: {
  config = {
    flake.nixosConfigurations.sunnyshore = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [
        inputs.determinate.nixosModules.default
        inputs.disko.nixosModules.disko
        inputs.sops-nix.nixosModules.sops
        self.nixosModules.alloy
        self.nixosModules.aly
        self.nixosModules.backups
        self.nixosModules.comin
        self.nixosModules.default
        self.nixosModules.k3s
        self.nixosModules.prometheusNode
        self.nixosModules.sunnyshore
        self.nixosModules.tailscale
        self.nixosModules.wireguardSinnoh
      ];

      specialArgs = {inherit self;};
    };

    blzrd.nodes.sunnyshore = {
      output = self.nixosConfigurations.sunnyshore.config.system.build.toplevel;
      type = "nixos";
      user = "root";
    };
  };
}
