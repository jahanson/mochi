{
  lib,
  buildGoModule,
  installShellFiles,
  fetchFromGitHub,
  gitUpdater,
  testers,
  mods,
}:

buildGoModule rec {
  pname = "mods";
  version = "1.5.0";
  commitHash = "820b22023653d1066f49b3b817dbfb3bcefbe2a1";

  src = fetchFromGitHub {
    owner = "charmbracelet";
    repo = "mods";
    rev = commitHash;
    # hash = "sha256-Niap2qsIJwlDRITkPD2Z7NCiJubkyy8/pvagj5Beq84=";
    hash = "sha256-VYe6qEDcsgr1E/Gtt+4lad2qtPeMKGINmhEk5Ed98Pw=";
  };

  vendorHash = "sha256-sLpFOoZq/xE0co5XegScUIOt8Ax/N3ROwQJIPvu8jts=";
  # vendorHash = "sha256-DaSbmu1P/umOAhG901aC+TKa3xXSvUbpYsaiYTr2RJs=";

  nativeBuildInputs = [
    installShellFiles
  ];

  ldflags = [
    "-s"
    "-w"
    "-X=main.Version=${version}-${commitHash}"
  ];

  # These tests require internet access.
  checkFlags = [ "-skip=^TestLoad/http_url$|^TestLoad/https_url$" ];

  passthru = {
    updateScript = gitUpdater {
      rev-prefix = "v";
      ignoredVersions = ".(rc|beta).*";
    };

    tests.version = testers.testVersion {
      package = mods;
      command = "HOME=$(mktemp -d) mods -v";
    };
  };

  postInstall = ''
    export HOME=$(mktemp -d)
    $out/bin/mods man > mods.1
    $out/bin/mods completion bash > mods.bash
    $out/bin/mods completion fish > mods.fish
    $out/bin/mods completion zsh > mods.zsh

    installManPage mods.1
    installShellCompletion mods.{bash,fish,zsh}
  '';

  meta = with lib; {
    description = "AI on the command line";
    homepage = "https://github.com/charmbracelet/mods";
    license = licenses.mit;
    maintainers = with maintainers; [ dit7ya caarlos0 ];
    mainProgram = "mods";
  };
}
