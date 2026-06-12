{ self, ... }:
{
  flake.overlays.default = _: p: self.packages.${p.stdenv.hostPlatform.system};
}
