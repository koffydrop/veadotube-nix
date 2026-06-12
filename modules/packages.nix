{ inputs, ... }:
{
  perSystem =
    { pkgs, system, ... }:
    let
      inherit (pkgs) callPackage;
      libfunnel = callPackage ../packages/libfunnel.nix { };
      veadotube = callPackage ../packages/veadotube.nix { inherit libfunnel; };
    in
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      packages = {
        inherit libfunnel;
        veadotube = veadotube.full;
        veadotube-mini = veadotube.mini;
      };
    };
}
