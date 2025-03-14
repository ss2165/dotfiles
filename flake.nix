{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, home-manager, nixpkgs }:
    let
      configuration = { pkgs, ... }: {
        # List packages installed in system profile. To search by name, run:
        # $ nix-env -qaP | grep wget
        environment.systemPackages =
          [
            pkgs.vim
            pkgs.devenv
          ];

        # Necessary for using flakes on this system.
        nix.settings.experimental-features = "nix-command flakes";

        # Enable alternative shell support in nix-darwin.
        # programs.fish.enable = true;

        # Set Git commit hash for darwin-version.
        system.configurationRevision = self.rev or self.dirtyRev or null;

        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        system.stateVersion = 6;

        # The platform the configuration will be used on.
        nixpkgs.hostPlatform = "aarch64-darwin";
        ids.gids.nixbld = 30000;


        users.users.seyon = {
          name = "seyon";
          home = "/Users/seyon";
        };

        homebrew = {
          enable = true;
          casks = [ "middleclick" "iterm2" ];
        };

        # Use a custom configuration.nix location.
        # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
        # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

        # Auto upgrade nix package and the daemon service.
        # services.nix-daemon.enable = true;

        # nixpkgs.config = { allowBroken = true; allowUnfree = true; };

        nix.settings.trusted-users = [ "seyon" ];

        programs.fish.enable = true;

      };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#FHWDM45WYW
      darwinConfigurations."FHWDM45WYW" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.seyon = import ./home.nix;

            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
          }
        ];
      };
    };
}
