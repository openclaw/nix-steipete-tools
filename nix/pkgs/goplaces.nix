{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "goplaces";
  version = "0.2.2-dev";

  src = fetchFromGitHub {
    owner = "joshp123";
    repo = "goplaces";
    rev = "a71fe3de986a78607d923f397113d7eb1babc111";
    hash = "sha256-Lufp9+fwcoluNZR9iDYoIJ1yu3sM/8Q/EOkAlq5VLdk=";
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
    homepage = "https://github.com/joshp123/goplaces";
    license = licenses.mit;
    platforms = platforms.darwin ++ platforms.linux;
    mainProgram = "goplaces";
  };
}
