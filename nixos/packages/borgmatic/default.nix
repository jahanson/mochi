{
  lib,
  python3,
  fetchFromGitHub,
}:
python3.pkgs.buildPythonApplication rec {
  pname = "borgmatic";
  version = "1.9.12";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "borgmatic-collective";
    repo = "borgmatic";
    rev = version;
    hash = "sha256-tTnk2xO5F5AoQICZGVnEj8v6kNA7Wkd8kzvm4i3r0kU=";
  };

  build-system = [
    python3.pkgs.setuptools
  ];

  dependencies = with python3.pkgs; [
    jsonschema
    packaging
    requests
    ruamel-yaml
  ];

  optional-dependencies = with python3.pkgs; {
    Apprise = [
      apprise
    ];
  };

  pythonImportsCheck = [
    "borgmatic"
  ];

  meta = {
    description = "Simple, configuration-driven backup software for servers and workstations";
    homepage = "https://github.com/borgmatic-collective/borgmatic/";
    changelog = "https://github.com/borgmatic-collective/borgmatic/blob/${src.rev}/NEWS";
    license = lib.licenses.gpl3Only;
    mainProgram = "borgmatic";
  };
}
