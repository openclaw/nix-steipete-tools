package internal

import (
	"errors"
	"fmt"
	"net"
	"net/http"
	"net/http/httptest"
	"net/url"
	"strings"
	"testing"
	"time"
)

type stubRoundTripper struct {
	fn func(*http.Request) (*http.Response, error)
}

func (s stubRoundTripper) RoundTrip(req *http.Request) (*http.Response, error) {
	return s.fn(req)
}

func TestHTTPClientBoundsHeadersOnly(t *testing.T) {
	transport := HTTPClient.Transport.(*http.Transport)
	if transport.ResponseHeaderTimeout != 30*time.Second || HTTPClient.Timeout != 0 {
		t.Fatal("expected a 30s response-header deadline without a body deadline")
	}
}

func TestLatestReleaseUsesHTTPClient(t *testing.T) {
	oldClient := HTTPClient
	oldBase := GitHubAPIBase
	t.Cleanup(func() {
		HTTPClient = oldClient
		GitHubAPIBase = oldBase
	})

	GitHubAPIBase = "http://example.invalid"
	var sawURL string
	HTTPClient = &http.Client{
		Transport: stubRoundTripper{fn: func(req *http.Request) (*http.Response, error) {
			sawURL = req.URL.String()
			return nil, errors.New("sentinel-http-client")
		}},
	}

	_, err := LatestRelease("openclaw/gogcli")
	if err == nil || !strings.Contains(err.Error(), "sentinel-http-client") {
		t.Fatalf("LatestRelease error = %v", err)
	}
	if !strings.Contains(sawURL, "http://example.invalid/repos/openclaw/gogcli/releases/latest") {
		t.Fatalf("request URL = %q", sawURL)
	}
}

func TestLatestReleaseTimesOutOnSilentPeer(t *testing.T) {
	ln, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { _ = ln.Close() })
	// Keep the accepted connection silent past the client deadline.
	// Closing or reading one request byte lets LatestRelease fail with
	// EOF/reset before HTTPClient.Timeout fires.
	keepOpen := make(chan struct{})
	t.Cleanup(func() { close(keepOpen) })
	go func() {
		conn, acceptErr := ln.Accept()
		if acceptErr != nil {
			return
		}
		defer func() { _ = conn.Close() }()
		<-keepOpen
	}()

	oldClient := HTTPClient
	oldBase := GitHubAPIBase
	t.Cleanup(func() {
		HTTPClient = oldClient
		GitHubAPIBase = oldBase
	})
	GitHubAPIBase = "http://" + ln.Addr().String()
	HTTPClient = newHTTPClient()
	HTTPClient.Transport.(*http.Transport).ResponseHeaderTimeout = 200 * time.Millisecond
	t.Cleanup(HTTPClient.CloseIdleConnections)

	_, err = LatestRelease("openclaw/gogcli")
	if err == nil {
		t.Fatal("expected timeout error")
	}
	var urlErr *url.Error
	if !errors.As(err, &urlErr) || !urlErr.Timeout() {
		t.Fatalf("expected timeout-specific url.Error, got %v", err)
	}
}

func TestLatestReleaseAllowsSlowBody(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.(http.Flusher).Flush()
		time.Sleep(200 * time.Millisecond)
		fmt.Fprint(w, `{"tag_name":"v1.2.3"}`)
	}))
	defer server.Close()
	oldClient, oldBase := HTTPClient, GitHubAPIBase
	t.Cleanup(func() { HTTPClient, GitHubAPIBase = oldClient, oldBase })
	HTTPClient = newHTTPClient()
	HTTPClient.Transport.(*http.Transport).ResponseHeaderTimeout = 50 * time.Millisecond
	t.Cleanup(HTTPClient.CloseIdleConnections)
	GitHubAPIBase = server.URL
	rel, err := LatestRelease("owner/repo")
	if err != nil {
		t.Fatal(err)
	}
	if rel.TagName != "v1.2.3" {
		t.Fatalf("release = %#v", rel)
	}
}
