# Yazi Configuration

My personal [Yazi](https://github.com/sxyazi/yazi) terminal file manager configuration.

## 🎯 Overview

This repository contains customized configuration files for Yazi - a blazing fast terminal file manager written in Rust. The configuration focuses on productivity with VSCode integration and intuitive keyboard shortcuts.

## 📁 Configuration Structure

```
~/.config/yazi/
├── yazi.toml      # Main configuration file
├── keymap.toml    # Keyboard shortcuts
├── theme.toml     # Theme settings
├── package.toml   # Package management
└── plugins/       # Installed plugins
    ├── jump-to-char.yazi/
    └── zoxide.yazi/
```

## ⚙️ Key Configuration Changes

### yazi.toml
- **Default Editor**: VSCode configured as the primary editor
- **File Operations**: Custom openers for different file types
  - Text/Code files → VSCode
  - Images/Videos/PDFs → System default app
  - Archives → System default app
- **Display Settings**:
  - `show_hidden = false` - Hidden files are not shown by default
  - `sort_by = "alphabetical"` - Files sorted alphabetically
  - `sort_dir_first = true` - Directories displayed before files
  - `linemode = "none"` - Clean display without file details
- **Preview Settings**: Optimized for performance with appropriate cache settings

### keymap.toml
Custom keyboard shortcuts for efficient navigation and file operations.

## ⌨️ Keyboard Shortcuts

### Navigation
| Key | Action | Description |
|-----|--------|-------------|
| `j` / `↓` | Move down | Navigate to next item |
| `k` / `↑` | Move up | Navigate to previous item |
| `h` / `←` | Go back | Parent directory |
| `l` / `→` | Enter | Enter directory |
| `Enter` | Enter directory | Open folder |
| `o` | Open file | Open with VSCode |
| `O` | Open folder in VSCode | Open current directory in VSCode |
| `gg` | Go to top | Jump to first item |
| `G` | Go to bottom | Jump to last item |

### Page Navigation
| Key | Action |
|-----|--------|
| `Ctrl+u` | Half page up |
| `Ctrl+d` | Half page down |
| `Ctrl+b` | Full page up |
| `Ctrl+f` | Full page down |

### File Operations
| Key | Action | Description |
|-----|--------|-------------|
| `Space` | Toggle selection | Select/deselect files |
| `a` | Create | Create new file/directory |
| `yy` | Copy | Copy selected files |
| `dd` | Cut | Cut selected files |
| `p` | Paste | Paste files |
| `P` | Force paste | Paste with overwrite |
| `dD` | Trash | Move to trash |
| `D` | Delete | Permanently delete |
| `r` | Rename | Rename file/directory |
| `x` | Extract | Extract archives (zip, tar, 7z, etc.) |

### Search & Filter
| Key | Action |
|-----|--------|
| `/` | Search |
| `?` | Search backward |
| `f` | Filter |
| `F` | Clear filter |

### View Options
| Key | Action |
|-----|--------|
| `.` | Toggle hidden files |
| `s` | Sort options |
| `v` | Visual mode |
| `V` | Visual line mode |
| `Ctrl+v` | Visual block mode |

### Tab Management
| Key | Action |
|-----|--------|
| `t` | New tab |
| `1-9` | Switch to tab |
| `Tab` | Next tab |
| `Shift+Tab` | Previous tab |

### Other
| Key | Action |
|-----|--------|
| `~` | Go to home |
| `@` | Go to root |
| `z` | Jump with zoxide |
| `;` | Shell command |
| `q` | Quit |

## 🔌 Installed Plugins

### jump-to-char.yazi
Quick navigation by jumping to specific characters in the file list.

### zoxide.yazi
Integration with [zoxide](https://github.com/ajeetdsouza/zoxide) for smart directory jumping based on usage frequency.
- Press `z` to activate zoxide jump

## 📦 Dependencies

- **Yazi**: Latest version (v0.3+)
- **VSCode**: For file editing
- **zoxide**: For smart directory navigation (optional)
- **Standard Unix tools**: `du`, `ls`, etc.

## 🚀 Installation

1. Install Yazi:
```bash
# macOS
brew install yazi

# Arch Linux
pacman -S yazi

# Other systems - build from source
cargo install --locked yazi-fm
```

2. Clone this configuration:
```bash
git clone <repository-url> ~/.config/yazi
```

3. Install optional dependencies:
```bash
# Install zoxide for smart jumping
brew install zoxide  # macOS
# or
cargo install zoxide
```

## 🎨 Theme

Using custom theme defined in `theme.toml` with optimized colors for terminal display.

## 💡 Tips

- Use `Space` to select multiple files for batch operations
- Press `x` on any archive file to extract it automatically
- Use `z` for smart directory jumping with zoxide
- Press `O` (Shift+o) to open the current folder in VSCode

## 📝 Notes

- File size display is disabled by default for better performance (`linemode = "none"`)
- Mouse support is enabled for click and scroll operations
- Archive extraction supports: zip, tar, tar.gz, tar.bz2, tar.xz, rar, 7z

## 🔧 Customization

To customize further, edit the configuration files:
- `yazi.toml` - General settings
- `keymap.toml` - Keyboard shortcuts
- `theme.toml` - Visual appearance

## 📄 License

This configuration is provided as-is for personal use.

## 🔗 References

- [Yazi Documentation](https://yazi-rs.github.io/docs/)
- [Yazi GitHub](https://github.com/sxyazi/yazi)