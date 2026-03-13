{
  pkgs ? import ./../rhino-core/nix/pkgs.nix { },
}:

let
  yarnpnp2nix = import ./../yarnpnp2nix/default.nix;
  yarnpnp2nixLib = yarnpnp2nix.lib.${pkgs.stdenv.system};

  workspace = yarnpnp2nixLib.mkYarnPackagesFromManifest {
    inherit pkgs;
    yarnManifest = import ./workspace/yarn-manifest.nix;
    packageOverrides."repro-pkg@workspace:packages/repro-pkg".build = ''
      echo CWD: $(pwd)
      echo "running with vitest.config.mjs from workspace: vitest --config ./vitest.config.mjs"
      vitest --config ./vitest.config.mjs

      echo "running with vitest.config.mjs from outside workspace: vitest --config ${./vitest.config.mjs}"
      vitest --config ${./vitest.config.mjs}
    '';
  };
  vitestFromRuntimeEnvInSandbox = pkgs.stdenvNoCC.mkDerivation {
    name = "vitestFromRuntimeEnvInSandbox";
    phases = [ "checkPhase" ];
    doCheck = true;
    checkPhase = ''
      cd ${./workspace/packages/repro-pkg}
      echo CWD: $(pwd)
      ${
        workspace."repro-pkg@workspace:packages/repro-pkg".shellRuntimeDevEnvironment
      }/bin/vitest --config ${./vitest.config.mjs}

      echo "" > $out
    '';
  };
in
{
  inherit vitestFromRuntimeEnvInSandbox;
  vitestDuringPkgBuild = workspace."repro-pkg@workspace:packages/repro-pkg";
}
