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
      echo "NODE_OPTIONS: $NODE_OPTIONS"
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

      # Find .pnp.cjs and copy it to $out
      PNP_FILE=$(find /tmp -name ".pnp.cjs" | head -n 1)
      if [ -n "$PNP_FILE" ]; then
        echo "Found .pnp.cjs at: $PNP_FILE"
        cp "$PNP_FILE" "$out"
      else
        echo ".pnp.cjs not found in /tmp"
        echo "Searching /build..."
        PNP_FILE=$(find /build -name ".pnp.cjs" | head -n 1)
        if [ -n "$PNP_FILE" ]; then
          echo "Found .pnp.cjs at: $PNP_FILE"
          cp "$PNP_FILE" "$out"
        else
           echo "Could not find .pnp.cjs anywhere"
           touch $out
        fi
      fi
    '';
  };
in
{
  inherit vitestFromRuntimeEnvInSandbox;
  vitestDuringPkgBuild = workspace."repro-pkg@workspace:packages/repro-pkg";
}
