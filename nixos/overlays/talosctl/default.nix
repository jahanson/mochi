{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  git,
}:
buildGoModule rec {
  pname = "talosctl";
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "siderolabs";
    repo = "talos";
    rev = "v${version}";
    hash = "sha256-j/GqAUP3514ROf64+ouvCg//9QuGoVDgxkNFqi4r+WE=";
  };

  vendorHash = "sha256-XvOMNyiHnemqnbOzWmzZXkr3+/ZgJDg8vjCtWFkCtLs=";

  ldflags = [
    "-s"
    "-w"
  ];

  subPackages = ["cmd/talosctl"];

  doCheck = false;

  # Configure offline build
  GOWORK = "off";
  GOPROXY = "off";
  # GO111MODULE = "on";
  GOSUMDB = "off";

  # Use vendored dependencies
  modVendorDir = "vendor";
  allowGoReference = true;

  preBuild = ''
    export GOFLAGS="-mod=vendor"
  '';

  nativeBuildInputs = [
    installShellFiles
    git
  ];

  postInstall = ''
    installShellCompletion --cmd talosctl \
      --bash <($out/bin/talosctl completion bash) \
      --fish <($out/bin/talosctl completion fish) \
      --zsh <($out/bin/talosctl completion zsh)
  '';

  meta = with lib; {
    description = "A CLI for out-of-band management of Kubernetes nodes created by Talos";
    homepage = "https://www.talos.dev/";
    license = licenses.mpl20;
    maintainers = with maintainers; [flokli];
    mainProgram = "talosctl";
  };
}
