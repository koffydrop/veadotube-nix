{
  autoPatchelfHook,
  copyDesktopItems,
  fetchItchIo,
  ffmpeg,
  freetype,
  harfbuzz,
  icu,
  imagemagick,
  lib,
  libfunnel,
  makeDesktopItem,
  makeWrapper,
  onnxruntime,
  openssl,
  rnnoise,
  rtmidi,
  sdl3,
  stdenvNoCC,
  symlinkJoin,
  unzip,
  wine64,
  overrideSrc ? null,
  itchApiKey ? null,
  edition ? "full",
  withWine ? true,
  winePrefix ? null,
}:

assert lib.assertOneOf "edition" edition [
  "full"
  "mini"
];

let
  consolidatedDeps = symlinkJoin {
    name = "veadotube-consolidated-deps";
    paths = [
      freetype
      harfbuzz
      libfunnel.lib
      # BUG: onnxruntime from nixpkgs crashes veadotube when used
      # onnxruntime
      rnnoise
      rtmidi
      sdl3.lib
    ];
  };

  derivationArgs = lib.optionalAttrs (itchApiKey != null) { env.NIX_ITCHIO_API_KEY = itchApiKey; };

  full = final: prev: {
    pname = "veadotube";
    version = "0.6-20260617a";

    src =
      if overrideSrc == null then
        fetchItchIo (src: {
          name = "veadotube-labs-veadotube-linux-x64.zip";
          gameUrl = "https://olmewe.itch.io/veadotube-labs";
          upload = "10658916";
          hash = "sha256-iZ8TSgK8q083188v3Q8uIpB4GegsOFyHTHJcef+yAs8=";
          inherit derivationArgs;
          extraMessage = lib.warn ''
            The full version of veadotube is currently in early access and can't be downloaded by nix.
            If this fails to build, add it manually to the nix store:

              nix store add-file /path/to/${src.name}

            or pass it as a source override:

              veadotube.override { overrideSrc = ./path/to/${src.name}; }
          '' "";
        })
      else
        overrideSrc;

    icon = ../assets/veadotube.ico;
  };

  mini = final: prev: {
    pname = "veadotube-mini";
    version = "2.2";

    src =
      if overrideSrc == null then
        fetchItchIo {
          name = "veadotube-mini-linux-x64.zip";
          gameUrl = "https://olmewe.itch.io/veadotube-mini";
          upload = "10108062";
          hash = "sha256-JHgC9nhMTr76zavmj8kzmdTyOwWFdSJ1lEpx26yAnrA=";
          inherit derivationArgs;
        }
      else
        overrideSrc;

    icon = ../assets/mini.ico;
  };
in

stdenvNoCC.mkDerivation (finalAttrs: {
  dontBuild = true;
  sourceRoot = ".";

  nativeBuildInputs = [
    makeWrapper
    autoPatchelfHook
    copyDesktopItems
    unzip
    imagemagick
  ];

  makeWrapperArgs = [
    "--set"
    "LD_LIBRARY_PATH"
    (lib.makeLibraryPath [
      icu
      openssl
    ])
  ]
  ++ lib.optionals withWine [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [ wine64 ])
  ]
  ++ lib.optionals (withWine && winePrefix != null) [
    "--run"
    ''export WINEPREFIX="${winePrefix}"''
    "--run"
    "[[ ! -e $WINEPREFIX ]] && mkdir -p $WINEPREFIX"
  ];

  installPhase = ''
    runHook preInstall

    makeWrapperArgs=(${lib.escapeShellArgs finalAttrs.makeWrapperArgs})

    mkdir -p $out/opt/$pname $out/bin

    rm lib/{rtmidi,sdl3,ffmpeg,rnnoise,libfunnel}*

    shopt -s extglob
    cp -r !(env-vars) $out/opt/$pname
    shopt -u extglob

    ln -s ${consolidatedDeps}/* $out/opt/$pname/lib
    ln -s ${ffmpeg}/bin/ffmpeg $out/opt/$pname/lib/ffmpeg

    mkdir -p $(magick identify -format '%wx%h\n' ${finalAttrs.icon} | sed -E "s/(.*)/''${out//\//\\/}\/share\/icons\/hicolor\/\1\/apps/g")
    magick ${finalAttrs.icon} -set filename:f "$out/share/icons/hicolor/%wx%h/apps/''${pname}.png" '%[filename:f]'

    makeWrapper "$out/opt/$pname/$pname" $out/bin/$pname ''${makeWrapperArgs[@]}
    makeWrapper "$out/opt/$pname/$pname" $out/bin/''${pname}-x11 --set SDL_VIDEODRIVER x11 ''${makeWrapperArgs[@]}

    substituteInPlace $out/opt/$pname/lib/input.sh --replace-fail '"$1" --toolset LinuxInput' "$out/bin/$pname --toolset LinuxInput"

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = finalAttrs.pname;
      desktopName = "VeadoTube" + lib.optionalString (lib.hasSuffix "mini" finalAttrs.pname) " mini";
      comment = finalAttrs.meta.description;
      icon = finalAttrs.pname;
      exec = finalAttrs.meta.mainProgram;
      terminal = false;
      categories = [
        "Graphics"
      ];
      actions.x11 = {
        name = "x11";
        exec = "${finalAttrs.pname}-x11";
      };
    })
  ];

  passthru = {
    full = finalAttrs.overrideAttrs full;
    mini = finalAttrs.overrideAttrs mini;
  };

  meta = {
    description = "a collection of tools for virtual puppetry made by olmewe and BELLA!";
    homepage = "https://veado.tube";
    mainProgram = finalAttrs.pname;
    platforms = [ "x86_64-linux" ];
    license = {
      free = false;
      redistributable = false;
      url = "https://veado.tube/docs/terms/";
    };
  };
})
