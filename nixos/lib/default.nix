{lib, ...}:
with lib; rec {
  firstOrDefault = first: default:
    if first != null
    then first
    else default;
  existsOrDefault = x: set: default:
    if builtins.hasAttr x set
    then builtins.getAttr x set
    else default;

  # Create custom package set
  mkMyPkgs = pkgs: {
    borgmatic = pkgs.callPackage ../../nixos/packages/borgmatic {};
  };

  # main service builder
  mkService = options: (
    let
      user = existsOrDefault "user" options "568";
      group = existsOrDefault "group" options "568";

      # enableBackups =
      #   (lib.attrsets.hasAttrByPath ["persistence" "folder"] options)
      #   && (lib.attrsets.attrByPath ["persistence" "enable"] true options);

      # Security options for containers
      containerExtraOptions =
        lib.optionals (lib.attrsets.attrByPath ["container" "caps" "privileged"] false options) [
          "--privileged"
        ]
        ++ lib.optionals (lib.attrsets.attrByPath ["container" "caps" "readOnly"] false options) [
          "--read-only"
        ]
        ++ lib.optionals (lib.attrsets.attrByPath ["container" "caps" "tmpfs"] false options) [
          (map (folders: "--tmpfs=${folders}") tmpfsFolders)
        ]
        ++ lib.optionals (lib.attrsets.attrByPath ["container" "caps" "noNewPrivileges"] false options) [
          "--security-opt=no-new-privileges"
        ]
        ++ lib.optionals (lib.attrsets.attrByPath ["container" "caps" "dropAll"] false options) [
          "--cap-drop=ALL"
        ];
    in {
      virtualisation.oci-containers.containers.${options.app} = mkIf options.container.enable {
        image = "${options.container.image}";
        user = "${user}:${group}";
        environment =
          {
            TZ = options.timeZone;
          }
          // options.container.env;
        environmentFiles = lib.attrsets.attrByPath ["container" "envFiles"] [] options;
        volumes =
          ["/etc/localtime:/etc/localtime:ro"]
          ++ lib.optionals (lib.attrsets.hasAttrByPath ["container" "persistentFolderMount"] options) [
            "${options.persistence.folder}:${options.container.persistentFolderMount}:rw"
          ]
          ++ lib.attrsets.attrByPath ["container" "volumes"] [] options;
        extraOptions = containerExtraOptions;
      };
      systemd.tmpfiles.rules = lib.optionals (lib.attrsets.hasAttrByPath [
          "persistence"
          "folder"
        ]
        options) ["d ${options.persistence.folder} 0750 ${user} ${group} -"];
    }
  );
}
