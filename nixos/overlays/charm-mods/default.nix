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
  version = "1.6.0";
  commitHash = "2a7f9d4dc11b6c828bf35a0b3d0be709f3ed79b9";

  src = fetchFromGitHub {
    owner = "charmbracelet";
    repo = "mods";
    rev = commitHash;
    hash = "sha256-23gtb8BOx/0c643/paRt7VFHEyMyF4Q4a5b5+a4+kNU=";
  };

  vendorHash = "sha256-RV/Nr60BpCLcUL2Yy1Dd2ScwoI0BhGhTb/igCEcJPjI=";

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
