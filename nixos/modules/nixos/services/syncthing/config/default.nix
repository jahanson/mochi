{ sops, ... }:
{
  settings = {
    gui = {
      user = sops.secrets.username;
      password = sops.secrets.password;
    };

    devices = {
      legiondary = {
        name = "legiondary";
        id = "O4WI2YC-BZBPF2W-2ALNQ2D-UOP3BK5-ZDSEHVH-DIHS2FG-BSVJCXG-GF47XAE";
      };
      shadowfax = {
        name = "shadowfax";
        id = "U3DS7CW-GBZT44M-IFP3MOB-AV6SHVY-YFVEL5P-HE3ACC5-NDDGAOB-HOTKJAC";
      };
      gandalf = {
        name = "gandalf";
        id = "2VYHSOB-4QE3UIJ-EFKAD4D-J7YTLYG-4KF36C2-3SOLD4G-MFR6NK3-C2VSAQV";
      };
      telchar = {
        name = "telchar";
        id = "ENO4NVK-DUKOLUT-ASJZOEI-IFBVBTA-GDNWKWS-DQF3TZW-JJ72VVB-VWTHNAH";
      };
    };

    folders = {
      "Documents" = {
        path = "/home/jahanson/projects";
        devices = [
          "legiondary"
          "shadowfax"
          "gandalf"
          "telchar"
        ];
      };
    };
  };
}
