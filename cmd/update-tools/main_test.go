package main

import "testing"

func TestQMDNodeModulesHash(t *testing.T) {
	upstream := `
nodeModulesHashes = {
  x86_64-linux = "sha256-linux";
  aarch64-darwin = "sha256-darwin";
};
`

	got, err := qmdNodeModulesHash(upstream, "aarch64-darwin")
	if err != nil {
		t.Fatal(err)
	}
	if got != "sha256-darwin" {
		t.Fatalf("got %q", got)
	}
}

func TestQMDNodeModulesHashRejectsFake(t *testing.T) {
	upstream := `
nodeModulesHashes = {
  aarch64-darwin = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
};
`

	_, err := qmdNodeModulesHash(upstream, "aarch64-darwin")
	if err == nil {
		t.Fatal("expected fake hash to be rejected")
	}
}
