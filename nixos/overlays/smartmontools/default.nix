{ ... }:
let
  dbrev = "5607";
  drivedbBranch = "RELEASE_7_4";
in
final: prev: {
  smartmontools = prev.smartmontools.overrideAttrs (oldAttrs: {
    inherit dbrev drivedbBranch;
    driverdb = builtins.fetchurl {
      url = "https://sourceforge.net/p/smartmontools/code/${dbrev}/tree/tags/${drivedbBranch}/smartmontools/drivedb.h?format=raw";
      sha256 = "sha256-BTZm9Ue7MxFygEValSs/d86Jz3xQU+4+EPdHO6erAmI=";
      name = "smartmontools-drivedb.h";
    };
  });
}
