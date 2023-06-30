# https://github.com/LnL7/nix-darwin/
{ config, pkgs, ... }: {
  imports = [ <home-manager/nix-darwin> ];

  users.users.seyon = {
    name = "seyon";
    home = "/Users/seyon";
  };
  home-manager.users.seyon = { pkgs, osConfig, ... }: {
    # https://nix-community.github.io/home-manager/index.html
    home.packages = [
      pkgs.nil
      pkgs.nixpkgs-fmt
    ];
    # programs.vim.enable = true;
    programs.gh.enable = true;
    programs.bat.enable = true;
    programs.exa.enable = true;
    programs.starship.enable = true;
    programs.direnv.enable = true;
    programs.direnv.nix-direnv.enable = true;
    programs.htop.enable = true;

    programs.fish = {
      enable = true;
      functions = {
        fish_greeting = {
          description = "Greeting to show when starting a fish shell";
          body = "";
        };
        finbr = {
          description = "Switch from a branch to main and delete the branch";
          body =
            "set -f CURBR $(git branch --show-current);\ngit switch main;\ngit pull;\ngit branch -D $CURBR";
        };

        vscodehook = {
          description = "Run vs code integrated terminal hook";
          body =
            "string match -q $TERM_PROGRAM vscode\nand . (code --locate-shell-integration-path fish)";
        };
      };
      shellAliases = {
        cat = "bat";
        ls = "exa";
        cfgit = "git --git-dir=$HOME/.cfg_git/ --work-tree=$HOME";
      };

      shellAbbrs = {
        g = "git ";
      };

      shellInit =
        "eval (${osConfig.homebrew.brewPrefix}/brew shellenv)\nvscodehook";
    };

    programs.git = {
      enable = true;
      aliases = {
        sw = "switch";
        re = "restore";
        br = "branch";
        ci = "commit";
        st = "status";
        pushf = "push --force-with-lease";
        amend = "commit --amend --no-edit";
        reword = "commit --amend";
        smartlog = "log --graph --pretty=format:'commit: %C(bold red)%h%Creset %C(red)<%H>%Creset %C(bold magenta)%d %Creset%ndate: %C(bold yellow)%cd %Creset%C(yellow)%cr%Creset%nauthor: %C(bold blue)%an%Creset %C(blue)<%ae>%Creset%n%C(cyan)%s%n%Creset'";
        slog = "smartlog";
      };
      userName = "Seyon Sivarajah";
      userEmail = "seyon.sivarajah@quantinuum.com";
      extraConfig = {
        core = {
          editor = "code";
          longpaths = true;
        };

        branch.autosetuprebase = "always";
        rebase = {
          autosquash = true;
          autostash = true;
        };

        pull.rebase = true;
        init.defaultBranch = "main";
        fetch.prune = true;
        sequence.editor = "code --wait";

      };

      ignores = [
        ".python-version"
        ".envrc"
        ".env"
        ".direnv"
        "setup.cfg"
        ".vscode"
        ".devenv*"
      ];
    };



    programs.home-manager.enable = true;
    home.stateVersion = "23.11";

  };


  environment.systemPackages = [
    # install devenv
    (import (fetchTarball "https://github.com/cachix/devenv/archive/v0.6.2.tar.gz")).default
  ];

  homebrew = {
    enable = true;
    casks = [ "middleclick" "iterm2" ];
  };

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = [ "seyon" ];

  programs.fish.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
