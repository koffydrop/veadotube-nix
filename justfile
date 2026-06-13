set lazy
latest-build := `printf "%s" "$(printf "%s\n" builds/full/* | sort -V - | tail -n 1)/veadotube-labs-veadotube-linux-x64.zip"`
latest-hash := shell('nix hash file "$1"', latest-build)

@setup-store:
  nix store add-file {{ latest-build }}
  printf "%s\n" "{{ latest-hash }}"
