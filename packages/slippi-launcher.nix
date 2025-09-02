{
  lib,
  libredirect,
  formats,
  runCommandLocal,
  slippi-netplay,
  slippi-playback,
  slippi-launcher-unwrapped,
  /*
    The full list of settings can be found here (remove the set and get and camel case, ie. getIsoPath -> isoPath):
    https://github.com/project-slippi/slippi-launcher/blob/572c4f94f4c75d5fd94b463920c9464b4ed05aee/src/settings/api.ts#L39-L65
  */
  settings ? {
    isoPath = "/home/nezia/Documents/roms/Super Smash Bros. Melee (USA) (En,Ja) (Rev 2).iso";
    netplayDolphinPath = lib.getExe slippi-netplay;
    playbackDolphinPath = lib.getExe slippi-playback;
    launchMeleeOnPlay = false;
  },
  netplayPackage ? slippi-netplay,
  playbackPackage ? slippi-playback,
}:
let
  inherit (lib.meta) getExe;
  inherit (lib.strings) optionalString;

  settingsFormat = formats.json { };
  settingsFile = settingsFormat.generate "slippi-config" { inherit settings; };
in
runCommandLocal slippi-launcher-unwrapped.name
  {
    inherit (slippi-launcher-unwrapped) pname version meta;
  }
  ''
    mkdir -p "$out/bin"
    ln -s "${slippi-launcher-unwrapped}/share" "$out/share"
    ln -s ${getExe slippi-launcher-unwrapped} "$out/bin/slippi-launcher"
    ${optionalString (settings != { }) ''
      mv $out/bin/slippi-launcher $out/bin/.slippi-launcher-wrapped

      cat > $out/bin/slippi-launcher <<EOF
      #!/bin/sh
      config_dir="\$HOME/.config/Slippi Launcher"
      settings_path="\$config_dir/Settings"

      mkdir -p "\$config_dir"
      if [ ! -e "\$settings_path" ]; then
        cp ${settingsFile} "\$settings_path"
      fi

      mkdir -p "\$config_dir/playback" "\$config_dir/netplay"
      ln -sf ${getExe playbackPackage} "\$config_dir/playback/Slippi_Playback-x86_64.AppImage"
      ln -sf ${getExe netplayPackage} "\$config_dir/netplay/Slippi_Online-x86_64.AppImage"

      exec $out/bin/.slippi-launcher-wrapped "\$@"
      EOF

      chmod +x $out/bin/slippi-launcher
    ''}
  ''
