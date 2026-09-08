package internal

import (
	"context"
	"fmt"
	"net/http"
	"net/http/httptest"
	"os"
	"os/exec"
	"strings"
	"testing"
	"time"
)

func TestSummarizePackageExtracts(t *testing.T) {
	binary := os.Getenv("SUMMARIZE_BIN")
	if binary == "" {
		t.Skip("set SUMMARIZE_BIN to the built Nix package's executable")
	}
	const marker = "Nix package extraction works"
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "text/html")
		fmt.Fprintf(w, "<html><head><title>%s</title></head><body><article><h1>%s</h1>%s</article></body></html>", marker, marker,
			strings.Repeat("<p>"+marker+". This synthetic article verifies that the packaged command can load its runtime dependencies and extract readable text from a web page.</p>", 20))
	}))
	defer server.Close()
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()
	cmd := exec.CommandContext(ctx, binary, server.URL, "--extract", "--plain", "--firecrawl", "off", "--timeout", "10s")
	cmd.WaitDelay = time.Second
	output, err := cmd.CombinedOutput()
	if err != nil {
		t.Fatalf("packaged summarize: %v: %s", err, output)
	}
	if !strings.Contains(string(output), marker) {
		t.Fatalf("extracted content does not contain the article text: %s", output)
	}
	t.Log("built summarize package extracted the synthetic HTTP article")
}
