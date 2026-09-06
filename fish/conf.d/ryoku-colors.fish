# Ryoku palette for fish and fzf. Rendered by the theme daemon; do not edit.
#
# Dropped straight into conf.d, which fish sources on its own, so nothing in the
# shipped config has to include it. Your ~/.config/fish/user.fish loads last and
# still wins.

# Syntax highlighting.
set -g fish_color_normal D3C6AA
set -g fish_color_command A7C080
set -g fish_color_keyword 83C092
set -g fish_color_quote 7FBBB3
set -g fish_color_redirection 9DA9A0
set -g fish_color_end 83C092
set -g fish_color_error E67E80
set -g fish_color_param D3C6AA
set -g fish_color_comment 9DA9A0
set -g fish_color_selection --background=2E383C
set -g fish_color_operator 83C092
set -g fish_color_escape 7FBBB3
set -g fish_color_autosuggestion 9DA9A0
set -g fish_color_cancel E67E80
set -g fish_color_search_match --background=2E383C
set -g fish_color_valid_path --underline

# Completion pager.
set -g fish_pager_color_progress 9DA9A0
set -g fish_pager_color_prefix A7C080
set -g fish_pager_color_completion D3C6AA
set -g fish_pager_color_description 9DA9A0
set -g fish_pager_color_selected_background --background=2E383C

# fzf takes the same palette, so Ctrl-R and Ctrl-T match the terminal they open
# in. Appended to whatever options are already set rather than replacing them.
set -gx FZF_DEFAULT_OPTS "$FZF_DEFAULT_OPTS \
--color=fg:#D3C6AA,bg:-1,hl:#A7C080 \
--color=fg+:#D3C6AA,bg+:#2E383C,hl+:#A7C080 \
--color=info:#7FBBB3,prompt:#A7C080,pointer:#83C092 \
--color=marker:#83C092,spinner:#7FBBB3,header:#9DA9A0 \
--color=border:#4c544f"
