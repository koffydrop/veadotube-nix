{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      files.file.LICENSE.source = pkgs.fetchurl {
        url = "https://www.gnu.org/licenses/gpl-3.0.txt";
        hash = "sha256-OXLcl0T2SZ8Pmy2/dmlvKuetivmyPd5m1q+Gyd+zaYY=";
      };
    };
}
