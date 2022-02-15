let

  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs {};

in

  pkgs.mkShell {
    buildInputs = [

      # Dev Tools
      pkgs.curl
      pkgs.just
      pkgs.simple-http-server
      pkgs.watchexec

      # Language Specific
      pkgs.elmPackages.elm
      pkgs.elmPackages.elm-format
      pkgs.haskellPackages.stack
      pkgs.nodejs-14_x
      pkgs.nodePackages.pnpm

      # Indirect dependencies
      pkgs.gmp
      pkgs.libiconv

    ];
  }
