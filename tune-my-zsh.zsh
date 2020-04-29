#!/usr/bin/env zsh

printf -v installed_pkg %s\\n $(apt-mark showmanual)

printf %s\\n "Checking required packages to install."
for pkg in (zsh fonts-powerline fonts-firacode); do
    # for pkg in $installed_pkg; do # How to reverse condition ? (i.e. `NOT in [list]`)
    if (( ! $(grep -c pkg $installed_pkg) )); then
        required_pkg+="$pkg"
    fi
done

#  The -v option causes the output to be stored as the value of the parameter 'name',
#+ instead of printed.
#  This is intented to counteract the very slowness of built-in command's substitution.
#  Use command's substitution only with external commands to achieve high performance's scripts.
#  TODO: replace `lsb_release` command with `cat /etc/os-release ID` (does it exit for VoidLinux
#+ and FreeBSD ?). Is `mawk` installed by default on those OS ?
if [ -z $required_pkg ]; then
    printf %s\\n "You already have all required packages, poursuing towards next step."
else
    printf -v distro %s\\n $(uname --kernel-version | mawk '{print $3}') # for Debian
    # for FreeBSD: uname --operating-system | awk '{print $2}'
    if [ $distro == "Debian" ]; then
        sudo apt install -y "$required_pkg"
    elif [ $distro == "VoidLinux" ]; then
        xpbs-install -y "$required_pkg"
    elif [ $distro == "FreeBSD" ]; then
        pkg install -y "$required_pkg"
fi

# Switch current shell to zsh
if (( ! $(grep -c "zsh" /etc/shells) )); then # Check out either 'zsh' is already installed
    echo '/usr/bin/zsh' | tee -a /etc/shells
fi
chsh -s /usr/bin/zsh

# Downloading Oh My Zsh framework
sh -c "$(curl -fsSL https://raw.githubuser.content.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
sh install.sh

exit 0 # Add potential error codes to a logging-book

#  If it is the first use of zsh, a newuser module pops-up and ask for a anwser
# /usr/share/zsh/5.7.1/scripts/newuser

#  Find a way to insert automatically '2' before it happens: if no startup file is found, create it
#+ and populate it with default-related content (i.e. /etc/zsh/newuser.zshrc.recommended)
#  Otherwise, the script will not be automated

if [ ! -e "~/.zshrc"]; then # If the rc file does NOT exist
    printf "Creating a new run-control file for zsh according to recommended official settings."
    cat /etc/zsh/newuser.zshrc.recommended > $HOME/.zshrc 2> $HOME/ERRORFILE
fi
# Type `find / | grep newuser` to check out all newusers-related files.

# Find 'robbyrussel' string in ~/.zshrc and replace it with 'spaceship'
sed -i 's/robbyrussel/spaceship/' $HOME/Downloads/myzsh

# echo "Your session will be terminated in 6 seconds to take into account the shell's switching. \
# Please save your work immediately."
# sleep 6
# xfce4-session-logout --logout # Work only with Xfce environment
exit 0