{ ... }:
let
  dbrev = "5613";
  drivedbBranch = "RELEASE_7_4";
in
final: prev: {
  smartmontools = prev.smartmontools.overrideAttrs (oldAttrs: {
    inherit dbrev drivedbBranch;
    driverdb = builtins.fetchurl {
      url = "https://sourceforge.net/p/smartmontools/code/${dbrev}/tree/trunk/smartmontools/drivedb.h?format=raw";
      sha256 = "sha256-6r7Pd298Ea55AXOLijUEQoJq+Km5cE+Ygti65yacdoM=";
      name = "smartmontools-drivedb.h";
    };
  });
}
