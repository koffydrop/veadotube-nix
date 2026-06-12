{ inputs, ... }:
{
  debug = true;
  systems = [ "x86_64-linux" ];
  imports = [ "${inputs.files}/flake-module.nix" ];
  perSystem =
    { pkgs, config, ... }:
    {
      devShells.default = pkgs.mkShellNoCC {
        packages = [ config.files.writer.drv ];
      };
    };
}
