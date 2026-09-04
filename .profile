

# Added by Toolbox App
export PATH="$PATH:/home/matthias/.local/share/JetBrains/Toolbox/scripts"


# Source /etc/profile to ensure system paths (e.g. flatpak) are available
if [ -f /etc/profile ]; then
    source /etc/profile
fi


# Added by Antigravity CLI installer
export PATH="/home/matthias/.local/bin:$PATH"
