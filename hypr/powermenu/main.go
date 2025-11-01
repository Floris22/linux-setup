package main

import (
	"os"
	"os/exec"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

type model struct {
	width, height int
	hover         int
}

var (
	title   = "⚙  Power Menu"
	lbl1    = "Logout"
	lbl2    = "Reboot"
	lbl3    = "Poweroff"

	btn = lipgloss.NewStyle().
		Foreground(lipgloss.Color("#000000")).
		Background(lipgloss.Color("#87CEEB")).
		Padding(1, 6).
		Margin(1, 2).
		Bold(true)

	btnHover = lipgloss.NewStyle().
		Foreground(lipgloss.Color("#FFFFFF")).
		Background(lipgloss.Color("#1E90FF")).
		Padding(1, 6).
		Margin(1, 2).
		Bold(true)

	btnInner = lipgloss.NewStyle().
		Foreground(lipgloss.Color("#000000")).
		Background(lipgloss.Color("#87CEEB")).
		Padding(1, 6).
		Bold(true)

	titleStyle = lipgloss.NewStyle().Foreground(lipgloss.Color("#87CEEB")).Bold(true).Padding(1, 0, 1, 0)

	marginTopBottom = 1
	marginLeftRight = 2
)

func main() {
	p := tea.NewProgram(model{}, tea.WithAltScreen(), tea.WithMouseAllMotion())
	if _, err := p.Run(); err != nil {
		os.Exit(1)
	}
}

func (m model) Init() tea.Cmd { return nil }

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		m.width, m.height = msg.Width, msg.Height

	case tea.MouseMsg:
		if msg.Action == tea.MouseActionMotion || msg.Action == tea.MouseActionPress {
			m.hover = m.hit(msg.X, msg.Y)
		}
		if msg.Action == tea.MouseActionPress && msg.Button == tea.MouseButtonLeft {
			switch m.hover {
			case 1:
				exec.Command("hyprctl", "dispatch", "exit").Run()
				return m, tea.Quit
			case 2:
				exec.Command("systemctl", "reboot").Run()
				return m, tea.Quit
			case 3:
				exec.Command("systemctl", "poweroff").Run()
				return m, tea.Quit
			}
		}

	case tea.KeyMsg:
		switch msg.String() {
		case "1":
			exec.Command("hyprctl", "dispatch", "exit").Run(); return m, tea.Quit
		case "2":
			exec.Command("systemctl", "reboot").Run(); return m, tea.Quit
		case "3":
			exec.Command("systemctl", "poweroff").Run(); return m, tea.Quit
		case "q", "esc":
			return m, tea.Quit
		}
	}
	return m, nil
}

func (m model) hit(x, y int) int {
	sTitle := titleStyle.Render(title)
	box1 := btn.Render(lbl1)
	box2 := btn.Render(lbl2)
	box3 := btn.Render(lbl3)

	w1Box, _ := lipgloss.Size(box1)
	w2Box, _ := lipgloss.Size(box2)
	_, _ = lipgloss.Size(box3)

	rowBox := lipgloss.JoinHorizontal(lipgloss.Center, box1, box2, box3)
	content := lipgloss.JoinVertical(lipgloss.Center, sTitle, rowBox)

	cw, ch := lipgloss.Size(content)
	startX := (m.width - cw) / 2
	startY := (m.height - ch) / 2

	// position of button row
	_, th := lipgloss.Size(sTitle)
	rowY := startY + th

	// inner widths and heights (no margins)
	w1Inner, h1Inner := lipgloss.Size(btnInner.Render(lbl1))
	w2Inner, h2Inner := lipgloss.Size(btnInner.Render(lbl2))
	w3Inner, h3Inner := lipgloss.Size(btnInner.Render(lbl3))
	_ = h2Inner
	_ = h3Inner

	// starting x positions of outer boxes
	box1X := startX
	box2X := startX + w1Box
	box3X := startX + w1Box + w2Box

	// inner positions = outer + margins
	inner1X := box1X + marginLeftRight
	inner2X := box2X + marginLeftRight
	inner3X := box3X + marginLeftRight
	innerY := rowY + marginTopBottom

	if x >= inner1X && x < inner1X+w1Inner && y >= innerY && y < innerY+h1Inner {
		return 1
	}
	if x >= inner2X && x < inner2X+w2Inner && y >= innerY && y < innerY+h2Inner {
		return 2
	}
	if x >= inner3X && x < inner3X+w3Inner && y >= innerY && y < innerY+h3Inner {
		return 3
	}
	return 0
}

func (m model) View() string {
	b1, b2, b3 := btn, btn, btn
	if m.hover == 1 {
		b1 = btnHover
	}
	if m.hover == 2 {
		b2 = btnHover
	}
	if m.hover == 3 {
		b3 = btnHover
	}

	row := lipgloss.JoinHorizontal(lipgloss.Center,
		b1.Render(lbl1),
		b2.Render(lbl2),
		b3.Render(lbl3),
	)

	content := lipgloss.JoinVertical(lipgloss.Center,
		titleStyle.Render(title),
		row,
	)

	return lipgloss.Place(m.width, m.height, lipgloss.Center, lipgloss.Center, content)
}

