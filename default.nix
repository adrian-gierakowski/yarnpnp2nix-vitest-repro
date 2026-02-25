{ pkgs ? import ./../rhino-core/nix/pkgs.nix {} } :

let
  yarnpnp2nix = import ./../yarnpnp2nix/default.nix;
  yarnpnp2nixLib = yarnpnp2nix.lib.${pkgs.stdenv.system};

  workspace = yarnpnp2nixLib.mkYarnPackagesFromManifest {
    inherit pkgs;
    yarnManifest = import ./workspace/yarn-manifest.nix;
  };
in
  workspace."repro-pkg@workspace:packages/repro-pkg".shellRuntimeDevEnvironment

