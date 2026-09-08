package internal

import (
	"io"
	"path/filepath"
	"testing"
)

func TestRunCommandStartupFailure(t *testing.T) {
	if err := RunCommand("", 0, io.Discard, io.Discard, filepath.Join(t.TempDir(), "missing-command")); err == nil {
		t.Fatal("expected command startup error")
	}
}
