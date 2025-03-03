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
  version = "1.7.0";
  commitHash = "bf8337f9f4c586aaa267f8019ac2d0daa3b30129";

  src = fetchFromGitHub {
    owner = "charmbracelet";
    repo = "mods";
    rev = commitHash;
    hash = "sha256-EoDia+7ObtpnTDjJMzOk9djyCrW0m9pIToNHEDZ8Ch8=";
  };

  vendorHash = "sha256-dnKvT3VcvidfDcgJ9FerjtReIOwvRZtJZiBwNx2BEQ8=";

  nativeBuildInputs = [
    installShellFiles
  ];

  ldflags = [
    "-s"
    "-w"
    "-X=main.Version=${version}-${commitHash}"
  ];

  # These tests require internet access.
  checkFlags = ["-skip=^TestLoad/http_url$|^TestLoad/https_url$"];

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
    maintainers = with maintainers; [
      dit7ya
      caarlos0
    ];
    mainProgram = "mods";
  };
}
