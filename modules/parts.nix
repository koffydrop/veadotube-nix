{ inputs, ... }:
{
  debug = true;
  systems = [ "x86_64-linux" ];
  imports = [ "${inputs.files}/flake-module.nix" ];
  perSystem =
    { pkgs, config, ... }:
    {
      devShells.default = pkgs.mkShellNoCC {
        packages = with pkgs; [
          bashInteractive
          just
        ];
        shellHook = ''
          ${pkgs.lib.getExe config.files.writer.drv}
        '';
      };
    };
}
