# this script rapidly sets up my Macintosh computer the way I like it!

# ------------------------ DEMONSTRATION CASES ----------------------------

function installCowsay() {
	echo "Installing cowsay..."
	(brew install cowsay)
}

function uninstallCowsay() {
	echo "Uninstalling cowsay..."
	(brew uninstall cowsay)
}

function executeCowsay() {
	(cowsay moo)
}
# -------------------------------------------------------------------------

# -------------------------- HELPER FUNCTIONS -----------------------------
function PutSymlink() {
	if [ -d "$1" ] || [ -f "$1" ]; then
		read "REPLY?A directory already exists for $2, do you want to overwrite it?"
		echo
		if [[ $REPLY =~ ^[Yy]$ ]]
		then
			"$3"
		fi
	fi
}
# -------------------------------------------------------------------------

function start() {

	# - PRECONFIGs -

	# Show hidden files
	echo "Setting hidden files to show..."
	(defaults write com.apple.Finder AppleShowAllFiles true && killall Finder)

	# - HOMEBREW INSTALLATION -
	echo "Installing homebrew..."
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

	(echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/dylan/.zprofile && eval "$(/opt/homebrew/bin/brew shellenv)")

	(brew tap Homebrew/bundle)

	# Install applications specified in the brewfile
	echo "Installing brewfile specifications..."
	(cp ~/Dropbox/Apps/Homebrew/Brewfile . && brew bundle)

	echo "Testing cowsay..."
	installCowsay
	executeCowsay
	uninstallCowsay

	# Import sublime settings
	echo "Provisioning sublime settings..."
	(cd ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/ && rm -r User && ln -s ~/Dropbox/Apps/Sublime/User)

	# Installing OhMyZsh
	echo "Installing Ohmyzsh..."
	(sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)")

	# Symlinking dotfiles
	echo "Symlinking dotfiles..."

	echo "[1] /.ssh"
	DIR="$HOME/.ssh"
	PutSymlink $DIR "ssh keys" "(ln -s -f ~/Dropbox/Apps/dot/ssh ~/.ssh)"


	echo "[2] .zshrc"
	DIR="$HOME/.zshrc"
	PutSymlink $DIR "zshrc" "(ln -s -f ~/Dropbox/Apps/dot/zshrc ~/.zshrc)"


	echo "[3] .zsh_history"
	DIR="$HOME/.zsh_history"
	PutSymlink $DIR "zsh_history" "(ln -s -f ~/Dropbox/Apps/dot/zsh_history ~/.zsh_history)"


}

function backup() {

	DIRS_TO_BACKUP=("FileZilla"
		"Homebrew"
		"dot"
		"Sublime"
		"iTerm"
		"Alfred")

	BACKUP_DIRPATHS=( "${DIRS_TO_BACKUP[@]/#/$HOME/Dropbox/Apps/}" )

	BACKUP_TARGET_DIR="$HOME/Dropbox/backups/"

	BACKUP_NAME=$USER-backup-$(date +%Y%m%d)

	echo "Creating backup snapshot of configurations..."

	mkdir -p $DROPBOX_TARGET_DIR

	if [ -d "~/Dropbox/Apps" ]; then
		BACKUP=$BACKUP_NAME.tgz
		# sudo?
		tar -PkcZf $DROPBOX_TARGET_DIR$BACKUP $BACKUP_DIRPATHS > /dev/null

		mv $BACKUP $BACKUP_TARGET_DIR

		echo "Backup complete."
	else
		echo "Error: Hmm, you don't have any folders to backup."
	fi


}

function push() {

	# Backup before pushing new preferences
	backup

	echo "Creating the Brewfile..."
	# (brew tap Homebrew/bundle && brew bundle dump)

	echo "Moving to dropbox..."
	# (mv -f Brewfile $HOME/Dropbox/Apps/Homebrew/)


}



"$@"