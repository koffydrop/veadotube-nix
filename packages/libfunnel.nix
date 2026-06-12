{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  cmake,
  pipewire,
  libgbm,
  libglvnd,
  vulkan-loader,
  libx11,
  wayland,
  wayland-protocols,
  wayland-scanner,
  glslang,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libfunnel";
  version = "unstable-2026-03-18";

  src = fetchFromGitHub {
    owner = "hoshinolina";
    repo = "libfunnel";
    rev = "779586dab6ad396ce4a363204c8b9a18f473ca5d";
    hash = "sha256-eBuWoE13PDWePSzxCNVFnuM0SRZ/HxzUtSgs0SFHu/c=";
  };

  nativeBuildInputs = [
    meson
    ninja
    cmake
    pkg-config
    glslang
  ];

  outputs = [
    "lib"
    "out"
    "dev"
  ];

  buildInputs = [
    pipewire
    libgbm
    libglvnd
    vulkan-loader
    libx11
    wayland
    wayland-protocols
    wayland-scanner
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Easy app-to-app frame sharing using PipeWire";
    homepage = "https://github.com/hoshinolina/libfunnel";
    license = lib.licenses.mit;
  };
})
