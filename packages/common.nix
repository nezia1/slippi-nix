{
  lib,
  appimageTools,
  makeWrapper,
  version,
  pname,
  src,
  appImageContents ? null,
  rawZip ? null,
  ...
}:
appimageTools.wrapType2 (
  {
    inherit
      version
      pname
      src
      appImageContents
      ;
    nativeBuildInputs = [ makeWrapper ];
    extraPkgs =
      pkgs: with pkgs; [
        curl
        zlib
        mpg123
      ];
    meta.mainProgram = pname;
  }
  // lib.optionalAttrs (rawZip != null) {
    passthru.raw-zip = rawZip;
  }
  // lib.optionalAttrs (appImageContents != null) {
    inherit appImageContents;
  }
)
