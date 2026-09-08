package internal

import (
	"context"
	"io"
	"os"
	"os/exec"
	"os/signal"
	"syscall"
	"time"
)

// RunCommand bounds both subprocess execution and inherited output pipes.
// A zero timeout leaves execution unlimited; interrupts still cancel it.
func RunCommand(dir string, timeout time.Duration, stdout, stderr io.Writer, name string, args ...string) error {
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()
	if timeout > 0 {
		var cancel context.CancelFunc
		ctx, cancel = context.WithTimeout(ctx, timeout)
		defer cancel()
	}
	cmd := exec.CommandContext(ctx, name, args...)
	cmd.Dir, cmd.Stdout, cmd.Stderr = dir, stdout, stderr
	cmd.WaitDelay = time.Second
	configureProcessGroup(cmd)
	err := cmd.Run()
	if err != nil {
		// Also clean up descendants if the parent exited before pipe draining.
		_ = killProcessGroup(cmd)
	}
	if ctx.Err() != nil {
		return ctx.Err()
	}
	return err
}
