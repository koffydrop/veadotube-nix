{ getSystem, ... }:
{
  # modified from https://github.com/hercules-ci/flake-parts/blob/40ee120dcc2c170d1180aa59bafbf046bb950706/extras/easyOverlay.nix#L44
  flake.overlays.default =
    final: prev:
    let
      system =
        prev.stdenv.hostPlatform.system or (prev.system
          or (throw "Could not determine the `hostPlatform` of Nixpkgs. Was this overlay loaded as a Nixpkgs overlay, or was it loaded into something else?")
        );
    in
    (getSystem system).packages;
}
