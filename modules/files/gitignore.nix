{ ... }:
{
  perSystem.files.file.".gitignore".text = ''
    .direnv/
    result*
  '';
}
