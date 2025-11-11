{
  description = "FHS compatible Julia dev env";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            cudaSupport = true;
          };
        };

        cudatoolkit = pkgs.cudaPackages_12.cudatoolkit;

        juliaFhsEnv = pkgs.buildFHSEnv {
          name = "julia-fhs-cuda-plotting-env";

          targetPkgs = pkgs: [
            pkgs.julia-bin
            pkgs.cmake
            pkgs.ninja
            cudatoolkit
            pkgs.xorg.libX11
            pkgs.mesa
            pkgs.fontconfig
            pkgs.glib
          ];

          profile = ''
            export JULIA_DEPOT_PATH="$PWD/.julia"
            echo "Entered FHS-compatible Julia development shell."
            echo "Using CUDA Toolkit version: ${cudatoolkit.version}"
            echo "Linking against HOST NVIDIA driver version: 570.153.02"
            echo "Julia packages will be stored in '$PWD/.julia'"
          '';
        };
      in
      {
        devShells.default = juliaFhsEnv.env;
      });
}
