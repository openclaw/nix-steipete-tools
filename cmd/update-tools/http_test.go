package main

import (
	"errors"
	"fmt"
	"net/http"
	"net/http/httptest"
	"net/url"
	"testing"
	"time"

	"github.com/openclaw/nix-openclaw-tools/internal"
)

func TestFetchTextHeaderTimeout(t *testing.T) {
	for _, slowBody := range []bool{false, true} {
		t.Run(fmt.Sprintf("slowBody=%t", slowBody), func(t *testing.T) {
			server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				if slowBody {
					w.WriteHeader(http.StatusOK)
					w.(http.Flusher).Flush()
				}
				time.Sleep(200 * time.Millisecond)
				fmt.Fprint(w, "upstream flake")
			}))
			defer server.Close()
			old := internal.HTTPClient
			t.Cleanup(func() { internal.HTTPClient = old })
			transport := old.Transport.(*http.Transport).Clone()
			transport.ResponseHeaderTimeout = 50 * time.Millisecond
			internal.HTTPClient = &http.Client{Transport: transport}
			t.Cleanup(internal.HTTPClient.CloseIdleConnections)
			t.Setenv("GH_TOKEN", "")
			body, err := fetchText(server.URL)
			if slowBody {
				if err != nil || body != "upstream flake" {
					t.Fatalf("body=%q err=%v", body, err)
				}
			} else {
				var timeout *url.Error
				if !errors.As(err, &timeout) || !timeout.Timeout() {
					t.Fatalf("expected header timeout, got %v", err)
				}
			}
		})
	}
}
