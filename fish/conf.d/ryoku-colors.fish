# Ryoku palette for fish and fzf. Rendered by the theme daemon; do not edit.
#
# Dropped straight into conf.d, which fish sources on its own, so nothing in the
# shipped config has to include it. Your ~/.config/fish/user.fish loads last and
# still wins.

# Syntax highlighting.
set -g fish_color_normal e5e2d8
set -g fish_color_command c9cc70
set -g fish_color_keyword deb7fd
set -g fish_color_quote c9c99d
set -g fish_color_redirection c9c7b4
set -g fish_color_end deb7fd
set -g fish_color_error ffb4ab
set -g fish_color_param e5e2d8
set -g fish_color_comment c9c7b4
set -g fish_color_selection --background=929540
set -g fish_color_operator deb7fd
set -g fish_color_escape c9c99d
set -g fish_color_autosuggestion c9c7b4
set -g fish_color_cancel ffb4ab
set -g fish_color_search_match --background=929540
set -g fish_color_valid_path --underline

# Completion pager.
set -g fish_pager_color_progress c9c7b4
set -g fish_pager_color_prefix c9cc70
set -g fish_pager_color_completion e5e2d8
set -g fish_pager_color_description c9c7b4
set -g fish_pager_color_selected_background --background=929540

# fzf takes the same palette, so Ctrl-R and Ctrl-T match the terminal they open
# in. Appended to whatever options are already set rather than replacing them.
set -gx FZF_DEFAULT_OPTS "$FZF_DEFAULT_OPTS \
--color=fg:#e5e2d8,bg:-1,hl:#c9cc70 \
--color=fg+:#e5e2d8,bg+:#929540,hl+:#c9cc70 \
--color=info:#c9c99d,prompt:#c9cc70,pointer:#deb7fd \
--color=marker:#deb7fd,spinner:#c9c99d,header:#c9c7b4 \
--color=border:#484839"
