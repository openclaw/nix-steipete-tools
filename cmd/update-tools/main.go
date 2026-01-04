package main

import (
	"fmt"
	"log"
	"os"
	"path/filepath"
	"regexp"
	"strings"

	"github.com/clawdbot/nix-steipete-tools/internal"
)

type Tool struct {
	Name       string
	Repo       string
	AssetRegex *regexp.Regexp
	NixFile    string
}

func updateTool(tool Tool) error {
	log.Printf("[update-tools] %s", tool.Name)
	rel, err := internal.LatestRelease(tool.Repo)
	if err != nil {
		return err
	}
	version := strings.TrimPrefix(rel.TagName, "v")
	var assetURL string
	for _, a := range rel.Assets {
		if tool.AssetRegex.MatchString(a.Name) {
			assetURL = a.BrowserDownloadURL
			break
		}
	}
	if assetURL == "" {
		return fmt.Errorf("no asset matched for %s", tool.Name)
	}
	hash, err := internal.PrefetchHash(assetURL)
	if err != nil {
		return err
	}

	if err := internal.ReplaceOnce(tool.NixFile, regexp.MustCompile(`version = "[^"]+";`), fmt.Sprintf(`version = "%s";`, version)); err != nil {
		return err
	}
	if err := internal.ReplaceOnce(tool.NixFile, regexp.MustCompile(`url = "[^"]+";`), fmt.Sprintf(`url = "%s";`, assetURL)); err != nil {
		return err
	}
	if err := internal.ReplaceOnce(tool.NixFile, regexp.MustCompile(`hash = "sha256-[^"]+";`), fmt.Sprintf(`hash = "%s";`, hash)); err != nil {
		return err
	}

	return nil
}

func updateOracle(repoRoot string) error {
	log.Printf("[update-tools] oracle")
	rel, err := internal.LatestRelease("steipete/oracle")
	if err != nil {
		return err
	}
	version := strings.TrimPrefix(rel.TagName, "v")
	var assetURL string
	for _, a := range rel.Assets {
		if matched, _ := regexp.MatchString(`oracle-[0-9.]+\.tgz`, a.Name); matched {
			assetURL = a.BrowserDownloadURL
			break
		}
	}
	if assetURL == "" {
		return fmt.Errorf("no asset matched for oracle")
	}
	assetHash, err := internal.PrefetchHash(assetURL)
	if err != nil {
		return err
	}
	lockURL := fmt.Sprintf("https://github.com/steipete/oracle/archive/refs/tags/%s.tar.gz", rel.TagName)
	lockHash, err := internal.PrefetchHash(lockURL)
	if err != nil {
		return err
	}

	oracleFile := filepath.Join(repoRoot, "nix", "pkgs", "oracle.nix")
	if err := internal.ReplaceOnce(oracleFile, regexp.MustCompile(`version = "[^"]+";`), fmt.Sprintf(`version = "%s";`, version)); err != nil {
		return err
	}
	if err := internal.ReplaceOnce(oracleFile, regexp.MustCompile(`url = "[^"]+";`), fmt.Sprintf(`url = "%s";`, assetURL)); err != nil {
		return err
	}
	if err := internal.ReplaceOnce(oracleFile, regexp.MustCompile(`hash = "sha256-[^"]+";`), fmt.Sprintf(`hash = "%s";`, assetHash)); err != nil {
		return err
	}
	lockRe := regexp.MustCompile(`(?s)lockSrc = fetchFromGitHub \{[^}]*hash = "sha256-[^"]+";`) 
	if err := internal.ReplaceOnceFunc(oracleFile, lockRe, func(s string) string {
		return regexp.MustCompile(`hash = "sha256-[^"]+";`).ReplaceAllString(s, fmt.Sprintf(`hash = "%s";`, lockHash))
	}); err != nil {
		return err
	}
	pnpmRe := regexp.MustCompile(`(?s)pnpmDeps.*hash = "sha256-[^"]+";`)
	if err := internal.ReplaceOnceFunc(oracleFile, pnpmRe, func(s string) string {
		return regexp.MustCompile(`hash = "sha256-[^"]+";`).ReplaceAllString(s, `hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";`)
	}); err != nil {
		return err
	}

	log.Printf("[update-tools] oracle: deriving pnpm hash")
	logText, _ := internal.NixBuildOracle()
	pnpmHash := internal.ExtractGotHash(logText)
	if pnpmHash == "" {
		return fmt.Errorf("oracle pnpm hash not found in build output")
	}
	if err := internal.ReplaceOnceFunc(oracleFile, pnpmRe, func(s string) string {
		return regexp.MustCompile(`hash = "sha256-[^"]+";`).ReplaceAllString(s, fmt.Sprintf(`hash = "%s";`, pnpmHash))
	}); err != nil {
		return err
	}
	return nil
}

func main() {
	repoRoot, err := os.Getwd()
	if err != nil {
		log.Fatal(err)
	}

	tools := []Tool{
		{"summarize", "steipete/summarize", regexp.MustCompile(`summarize-macos-arm64-v[0-9.]+\.tar\.gz`), filepath.Join(repoRoot, "nix", "pkgs", "summarize.nix")},
		{"gogcli", "steipete/gogcli", regexp.MustCompile(`gogcli_[0-9.]+_darwin_arm64\.tar\.gz`), filepath.Join(repoRoot, "nix", "pkgs", "gogcli.nix")},
		{"camsnap", "steipete/camsnap", regexp.MustCompile(`camsnap-macos-arm64\.tar\.gz`), filepath.Join(repoRoot, "nix", "pkgs", "camsnap.nix")},
		{"sonoscli", "steipete/sonoscli", regexp.MustCompile(`sonoscli-macos-arm64\.tar\.gz`), filepath.Join(repoRoot, "nix", "pkgs", "sonoscli.nix")},
		{"bird", "steipete/bird", regexp.MustCompile(`bird-macos-universal-v[0-9.]+\.tar\.gz`), filepath.Join(repoRoot, "nix", "pkgs", "bird.nix")},
		{"peekaboo", "steipete/peekaboo", regexp.MustCompile(`peekaboo-macos-universal\.tar\.gz`), filepath.Join(repoRoot, "nix", "pkgs", "peekaboo.nix")},
		{"poltergeist", "steipete/poltergeist", regexp.MustCompile(`poltergeist-macos-universal-v[0-9.]+\.tar\.gz`), filepath.Join(repoRoot, "nix", "pkgs", "poltergeist.nix")},
		{"sag", "steipete/sag", regexp.MustCompile(`sag_[0-9.]+_darwin_universal\.tar\.gz`), filepath.Join(repoRoot, "nix", "pkgs", "sag.nix")},
		{"imsg", "steipete/imsg", regexp.MustCompile(`imsg-macos\.zip`), filepath.Join(repoRoot, "nix", "pkgs", "imsg.nix")},
	}

	for _, tool := range tools {
		if err := updateTool(tool); err != nil {
			log.Fatalf("update %s failed: %v", tool.Name, err)
		}
	}

	if err := updateOracle(repoRoot); err != nil {
		log.Fatalf("update oracle failed: %v", err)
	}
}
