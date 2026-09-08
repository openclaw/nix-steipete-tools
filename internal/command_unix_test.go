//go:build unix

package internal

import (
	"bytes"
	"context"
	"errors"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"syscall"
	"testing"
	"time"
)

func TestRunCommandCleansDescendants(t *testing.T) {
	for _, parentExit := range []string{"wait", "exit 0", "exit 7"} {
		t.Run(parentExit, func(t *testing.T) {
			pidfile := filepath.Join(t.TempDir(), "pid")
			script := `sleep 60 & echo $! > "$1"; ` + parentExit
			var out bytes.Buffer
			start := time.Now()
			err := RunCommand("", 2*time.Second, &out, &out, "sh", "-c", script, "sh", pidfile)
			if err == nil {
				t.Fatal("expected a deadline, retained-pipe, or exit error")
			}
			if parentExit == "wait" && !errors.Is(err, context.DeadlineExceeded) {
				t.Fatalf("expected deadline, got %v", err)
			}
			if time.Since(start) > 5*time.Second {
				t.Fatalf("cleanup took %s", time.Since(start))
			}
			b, readErr := os.ReadFile(pidfile)
			if readErr != nil {
				t.Fatal(readErr)
			}
			var pid int
			if _, err := fmt.Sscanf(string(b), "%d", &pid); err != nil || pid <= 0 {
				t.Fatalf("invalid child PID %q", b)
			}
			t.Cleanup(func() { _ = syscall.Kill(pid, syscall.SIGKILL) })
			for deadline := time.Now().Add(time.Second); ; {
				state, err := exec.Command("ps", "-o", "stat=", "-p", fmt.Sprint(pid)).Output()
				if err != nil || strings.TrimSpace(string(state)) == "" || strings.HasPrefix(strings.TrimSpace(string(state)), "Z") {
					break
				}
				if time.Now().After(deadline) {
					t.Fatalf("descendant %d still running: %s", pid, state)
				}
				time.Sleep(10 * time.Millisecond)
			}
		})
	}
}

func TestRunCommandPreservesOutputAndExitStatus(t *testing.T) {
	var stdout, stderr bytes.Buffer
	err := RunCommand("", 0, &stdout, &stderr, "sh", "-c", "printf output; printf diagnostic >&2; exit 7")
	var exit *exec.ExitError
	if !errors.As(err, &exit) || exit.ExitCode() != 7 || stdout.String() != "output" || stderr.String() != "diagnostic" {
		t.Fatalf("stdout=%q stderr=%q err=%v", stdout.String(), stderr.String(), err)
	}
	stdout.Reset()
	if err := RunCommand("", 0, &stdout, &stderr, "sh", "-c", "printf success"); err != nil || stdout.String() != "success" {
		t.Fatalf("stdout=%q err=%v", stdout.String(), err)
	}
}

func TestRunCommandInterruptHelper(t *testing.T) {
	if os.Getenv("COMMAND_INTERRUPT_HELPER") == "" {
		return
	}
	var output bytes.Buffer
	err := RunCommand("", 0, &output, &output, "sh", "-c", `echo ready > "$1"; exec sleep 60`, "sh", os.Getenv("COMMAND_READY_FILE"))
	if !errors.Is(err, context.Canceled) {
		t.Fatalf("expected interrupt cancellation, got %v", err)
	}
}

func TestRunCommandHandlesInterrupt(t *testing.T) {
	ready := filepath.Join(t.TempDir(), "ready")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	cmd := exec.CommandContext(ctx, os.Args[0], "-test.run=^TestRunCommandInterruptHelper$")
	cmd.Env = append(os.Environ(), "COMMAND_INTERRUPT_HELPER=1", "COMMAND_READY_FILE="+ready)
	var output bytes.Buffer
	cmd.Stdout, cmd.Stderr = &output, &output
	if err := cmd.Start(); err != nil {
		t.Fatal(err)
	}
	defer func() { _ = cmd.Process.Kill() }()
	for {
		if _, err := os.Stat(ready); err == nil {
			break
		}
		if ctx.Err() != nil {
			t.Fatal("helper did not start")
		}
		time.Sleep(10 * time.Millisecond)
	}
	if err := cmd.Process.Signal(os.Interrupt); err != nil {
		t.Fatal(err)
	}
	if err := cmd.Wait(); err != nil {
		t.Fatalf("interrupt helper: %v: %s", err, output.String())
	}
}
