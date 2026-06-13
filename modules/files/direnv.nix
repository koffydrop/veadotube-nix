{ ... }:
{
  perSystem.files.file.".envrc".text = ''
    watch_file modules/parts.nix
    watch_file modules/files
    use flake
  '';
}
