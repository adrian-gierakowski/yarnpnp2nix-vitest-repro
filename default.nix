{ pkgs ? import ../rhino-core/nix/pkgs.nix {} } :

let
  yarnpnp2nix = import ../yarnpnp2nix/default.nix;
  # On macOS, (import /Users/m1/code/yarnpnp2nix/default.nix).lib might work if default.nix exports it
  # Looking at yarnpnp2nix/flake.nix, the lib is exported per system.
  yarnpnp2nixLib = (import ../yarnpnp2nix/default.nix).lib.${pkgs.stdenv.system};

  workspace = yarnpnp2nixLib.mkYarnPackagesFromManifest {
    inherit pkgs;
    yarnManifest = import ./workspace/yarn-manifest.nix;
  };
in
  workspace."repro-pkg@workspace:packages/repro-pkg"

