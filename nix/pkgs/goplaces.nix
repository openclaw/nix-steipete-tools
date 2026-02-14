{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "goplaces";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "steipete";
    repo = "goplaces";
    rev = "v${version}";
    hash = "sha256-D54ybZznbc0EXNh/SqyIvfn5x3krI3G9fbXTTj1BaEs=";
  };

  subPackages = [ "cmd/goplaces" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/steipete/goplaces/internal/cli.Version=${version}"
  ];

  vendorHash = "sha256-OFTjLtKwYSy4tM+D12mqI28M73YJdG4DyqPkXS7ZKUg=";

  meta = with lib; {
    description = "Modern Go client + CLI for the Google Places API";
    homepage = "https://github.com/steipete/goplaces";
    license = licenses.mit;
    platforms = platforms.darwin ++ platforms.linux;
    mainProgram = "goplaces";
  };
}
