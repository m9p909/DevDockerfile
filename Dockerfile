FROM greyltc/archlinux-aur:paru

USER 0

# Install dependencies for building stuff
RUN pacman -Syu --noconfirm git base-devel curl

# Install shell
RUN pacman -Syu --noconfirm zsh

# Create user
RUN groupadd -g 1000 user
RUN useradd -r -u 1000 -g 1000 -s /usr/bin/zsh user
RUN usermod -d /work -m user

# Cmake
RUN pacman -Syu --noconfirm clang cmake

# Prepare home for user
RUN mkdir /work
RUN chown 1000:1000 /work
WORKDIR /work

USER 1000

# Install node
USER 0
RUN pacman -Syu --noconfirm nodejs yarn

# Add some common stuff
RUN pacman -Syu --noconfirm htop ripgrep fzf jq

# Ctags
RUN pacman -Syu --noconfirm ctags

# Install neovim stuff
RUN pacman -Syu --noconfirm python-pynvim neovim

# Install tmux stuff
RUN pacman -Syu --noconfirm tmux

# Install language version manager
USER 1000
RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.7.6
RUN echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.zshrc
RUN echo -e '\n. $HOME/.asdf/completions/asdf.bash' >> ~/.zshrc

# Disable cache
#ADD "https://www.random.org/cgi-bin/randbyte?nbytes=10&format=h" /tmp/skipcache

# Setup zsh and plugins
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

RUN echo "alias vim=nvim" >> ~/.zshrc
RUN echo 'alias tmux="tmux -2"' >> ~/.zshrc
# Download my dotfiles
USER 1000
RUN git clone https://github.com/m9p909/Mnvim.git ~/.config/nvim


# Install plugins inside of vim
RUN nvim --headless "+Lazy! install" +qa

# Install .tmux
RUN curl https://gist.githubusercontent.com/m9p909/e1b6b7bc82d257fe7d5a9da360e51c86/raw/6e171e5f6a4706ede31e62ba1843c88037f45a1d/.tmux.conf > ~/.tmux.conf

RUN sed -i '/^set-option -g default-command/d' ~/.tmux.conf

# Prepare work area
USER 1000
WORKDIR /work

CMD ["tmux", "-2"]
