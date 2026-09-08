//go:build !unix

package internal

import (
	"os"
	"os/exec"
)

func configureProcessGroup(*exec.Cmd) {}

func killProcessGroup(cmd *exec.Cmd) error {
	if cmd.Process == nil {
		return os.ErrProcessDone
	}
	return cmd.Process.Kill()
}
