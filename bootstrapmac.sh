#!/usr/bin/env bash

fortranlink='http://coudert.name/software/gfortran-4.8.2-Mavericks.dmg'
xquartzlink='http://xquartz.macosforge.org/downloads/SL/XQuartz-2.7.4.dmg'
pkginlink='http://saveosx.org/packages/Darwin/bootstrap/bootstrap-x86_64.pkg'
qtlink='http://www.riverbankcomputing.com/static/Downloads/PyQt4/PyQt-mac-gpl-4.10.4-snapshot-f62fabcefe39.tar.gz'
pysidelink='http://pyside.markus-ullmann.de/pyside-1.1.0-qt47-py27apple.pkg'
rlink='http://stat.ethz.ch/CRAN/bin/macosx/R-latest.pkg'


sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

echo Configuring git
git config --global user.name “Tony Fischetti”
git config --global user.email “tony.fischetti@gmail.com”
git config --global credential.helper osxkeychain

echo Downloading fortran compiler
curl -o gfortran.dmg $fortranlink

hdiutil mount gfortran.dmg -mountpoint "./mnt"
cd mnt
cd $(ls)
echo About to install fortran compiler
sudo installer -pkg $(ls) -target '/'
cd ../../
sleep 5
hdiutil unmount ./mnt
rm gfortran.dmg
echo Fortran finished

###############################################

echo Downloading XQuartz
curl -o xquartz.dmg $xquartzlink

hdiutil mount xquartz.dmg -mountpoint "./mnt"
cd mnt
echo About to install XQuartz
sudo installer -pkg $(ls) -target '/'
cd ..
sleep 5
hdiutil unmount ./mnt
rm xquartz.dmg
echo XQuartz finished

###############################################

echo Downloading pkgin bootstrapper
mkdir tmp
cd tmp
curl -o pkgin.pkg $pkginlink
sudo installer -pkg $(ls) -target '/'
cd ..
rm -rf ./tmp

###############################################

echo Downloading Qt4
curl -o qt.dmg $qtlink

hdiutil mount qt.dmg -mountpoint "./mnt"
cd mnt
sudo installer -pkg Qt.mpkg -target '/'
cd ..
sleep 5
hdiutil unmount ./mnt
rm qt.dmg
echo Qt finished

###############################################

echo Cloning pkgsrc from git mirror
sudo git clone https://github.com/jsonn/pkgsrc.git /usr/pkgsrc
cd /usr/pkgsrc/
sudo git pull
 
###############################################
 
echo Updating PATH
echo 'export PATH="/usr/pkg/sbin:/usr/pkg/bin:$PATH"' > ~/.profile
export PATH="/usr/pkg/sbin:/usr/pkg/bin:$PATH"
 
###############################################

echo Installing zsh
cd /usr/pkgsrc/shells/zsh
sudo bmake
sudo bmake install
sudo bmake clean
sudo bmake clean-depends

###############################################

echo Installing cairo
cd /usr/pkgsrc/graphics/cairo
sudo bmake
sudo bmake install
libtool --finish /usr/pkg/lib/cairo
sudo bmake clean
sudo bmake clean-depends

###############################################

echo Updating pkgin
sudo pkgin -y update
echo Installing mercurial
sudo pkgin -y install mercurial
echo Installing wget
sudo pkgin -y install wget
echo Installing freetype2
sudo pkgin -y install freetype2
echo Installing pkg-config
sudo pkgin -y install pkg-config
echo Installing libxml2
sudo pkgin -y install libxml2
echo Installing sqlite3
sudo pkgin -y install sqlite3

###############################################

echo Python package installation spree!
echo Installing pip
sudo easy_install pip
echo Installing readline
sudo pip install readline
echo Installing nose
sudo pip install nose
echo Installing six
sudo pip install six
echo Installing pyparsing
sudo pip install pyparsing
echo Installing python-dateutil
sudo pip install python-dateutil
echo Installing pytz
sudo pip install pytz
echo Installing tornado
sudo pip install tornado
echo Installing pyzmq
sudo pip install pyzmq
echo Installing jinja2
sudo pip install jinja2
echo Installing pika
sudo pip install pika
echo Installing patsy
sudo pip install patsy
echo Installing pygments
sudo pip install pygments
echo Installing sphinx
sudo pip install sphinx
echo Installing scipy
sudo pip install scipy
echo Installing mercurial
sudo pip install mercurial
echo Installing requests
sudo pip install requests
echo Installing argparse
sudo pip install argparse
echo Installing dicttoxml
sudo pip install dicttoxml
echo Installing pudb
sudo pip install pudb
echo Installing datetime
sudo pip install datetime
echo Installing freebase
sudo pip install freebase
echo Installing networkx
sudo pip install networkx
echo Installing pyyaml
sudo pip install pyyaml
echo Installing twitter
sudo pip install twitter
echo Installing simplejson
sudo pip install simplejson
echo Installing lxml
sudo pip install lxml
echo Installing pandas
sudo pip install pandas
echo Installing pymc
sudo pip install pymc
echo Installing scikit-learn
sudo pip install scikit-learn
echo Installing statsmodels
sudo pip install statsmodels


###############################################

echo Downloading py2cairo
git clone https://github.com/dieterv/py2cairo.git
cd py2cairo
./waf configure
cd build_directory/c4che/
cp ../../../waffix.patch ./
patch < waffix.patch
cd ../../
./waf build
sudo ./waf install
#cd ..
rm -rf py2cairo
echo py2cairo finished

###############################################

echo Downloading SIP -- dependency of pyqt4
hg clone http://www.riverbankcomputing.com/hg/sip
cd sip
python ./configure.py
make
sudo make install
cd ..
rm -rf sip

###############################################

echo Downloading PyQt
mkdir tmp
curl -o pyqt.tar.gz $qtlink
tar xvzf pyqt.tar.gz -C tmp
cd tmp
cd $(ls)
python configure-ng.py --confirm-license --sip /System/Library/Frameworks/Python.framework/Versions/2.7/bin/sip
echo Building pyqt -- this will take a very long time
make
sudo make install
cd ../../
rm -rf ./tmp
rm pyqt.tar.gz

###############################################

echo Downloading PySide
curl -o pyside.pkg $pysidelink
sudo installer -pkg pyside.pkg -target '/'
rm pyside.pkg
echo Pyside finished

###############################################

echo Updrading matplotlib
sudo pip install --upgrade matplotlib
sudo chown $USER .matplotlib


###############################################


###############################################

echo Finally finished with python, lets start R
curl -o R.pkg $rlink
sudo installer -pkg R.pkg -target '/'
rm R.pkg
echo Finished R

echo Populating .Rprofile with preffered mirror
echo 'options(repos=structure(c(CRAN="http://cran.revolutionanalytics.com")))' > ~/.Rprofile

echo Running R bootstrapper
chmod +x Rbootstrap.R
./Rbootstrap.R
echo Finished R bootstrap

###############################################


###############################################

echo R is done, now lets do vim
echo Cloning Vim from mercurial
hg clone https://vim.googlecode.com/hg/ vim
cd vim
hg pull
hg update
./configure "CFLAGS=-O3" --prefix=/usr/local --enable-rubyinterp --enable-pythoninterp --enable-perlinterp --with-features=huge --enable-gui=no --without-x --disable-nls --enable-multibyte --with-tlib=ncurses  --with-compiledby=Tony.Fischetti
make
sudo make install
cd ..
rm -rf vim
echo CL Vim is finished

echo Cloning MacVim from git
git clone https://github.com/b4winckler/macvim.git
cd macvim
./configure "CFLAGS=-O3" --with-features=huge --enable-ruby-interp --enable-pythoninterp --enable-perlinterp --enable-cscope  --enable-multibyte --with-tlib=ncurses --with-compiledby=Tony.Fischetti --with-ruby-command=/usr/bin/ruby --with-macarchs=x86_64 --with-macsdk=10.8 --enable-fail-if-missing --disable-netbeans --with-developer-dir=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform
make
sudo cp -R src/MacVim/build/Release/MacVim.app /Applications
sudo cp src/MacVim/mvim /usr/local/bin
cd ..
rm -rf macvim
echo MacVim finished

echo Cloning tony-vim environment from git
git clone https://github.com/tonyfischetti/tony-vim.git ~/.vim
ln -s ~/.vim/.vimrc ~/.vimrc
ln -s ~/.vim/.gvimrc ~/.gvimrc
cd ~/.vim/
git submodule init
git submodule update



# TODO: make it fail if anything fails
#       ask if Xcode and gatekeeper is turned off
#       setup defaults and preferences
#       like zsh being the default shell
#       was zsh properly configured?
#       nltk and java are still not set up
#       neither is R studio



###################
## old bootstrap ##
###################

# #!/usr/bin/env bash
# 
# sudo -v
# while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
# 
# cd ~/Desktop
# echo Beginning bootstrap
# 
# # cop the packages
# 
# cd packages
# #sudo installer -pkg gfortran.pkg -target '/'
# #sudo installer -pkg xquartz.pkg -target '/'
# #sudo installer -pkg pkgin.pkg -target '/'
# #cd Qt
# #sudo installer -pkg Qt.mpkg -target '/'
# #cd ..
# 
# #git config --global user.name “Tony Fischetti”
# #git config --global user.email “tony.fischetti@gmail.com”
# #git config --global credential.helper osxkeychain
# #sudo git clone https://github.com/jsonn/pkgsrc.git /usr/pkgsrc
# 
# #cd /usr/pkgsrc/
# #sudo git pull
# 
# #echo 'export PATH="/usr/pkg/sbin:/usr/pkg/bin:$PATH"' > ~/.profile
# #export PATH="/usr/pkg/sbin:/usr/pkg/bin:$PATH"
# 
# #cd /usr/pkgsrc/shells/zsh
# #sudo bmake
# #sudo bmake install
# 
# #cd /usr/pkgsrc/graphics/cairo
# #sudo bmake
# #sudo bmake install
# #libtool --finish /usr/pkg/lib/cairo
# 
# #mkdir -p ~/.zsh/
# #mv ~/Desktop/completion.zsh ~/.zsh/
# #mv ~/Desktop/zshrc.txt ~/.zshrc
# 
# # MIND THE DIRECTORIES
# 
# #chsh -s /usr/pkg/bin/zsh $USER
# 
# #git clone https://github.com/tonyfischetti/tony-vim.git ~/.vim
# #ln -s ~/.vim/.vimrc ~/.vimrc
# #ln -s ~/.vim/.gvimrc ~/.gvimrc
# # cd ~/.vim/
# # git submodule init
# # git submodule update
# 
# #sudo easy_install pip
# #sudo pip install readline
# #sudo pip install nose
# #sudo pip install six
# #sudo pip install pyparsing
# #sudo pip install python-dateutil
# #sudo pip install pytz
# #sudo pip install tornado
# #sudo pip install pyzmq
# #sudo pip install jinja2
# #sudo pip install pika
# #sudo pip install patsy
# #sudo pip install pygments
# #sudo pip install sphinx
# #sudo pip install scipy
# 
# #sudo pkgin -y update 
# #sudo pkgin -y install freetype2 pkg-config
# #cd wx
# #sudo installer -pkg wxPython2.8-osx-unicode-universal-py2.7.pkg -target '/'
# 
# # WXPYTHON doesn't seem to work well
# 
# #tar xvzf py2cairo.tar.gz
# #cd py2cairo
# #./waf configure
# #cd build_directory/c4che/
# #cp ../../../patches/waffix.patch ./
# #patch < waffix.patch
# #cd ../../
# #./waf build
# #sudo ./waf install
# # HAD TO PATCH py2cairo at build_directory/c4che/_cache.py
# 
# # tar xvzf sip.tar.gz
# # cd sip
# # python configure.py
# # make
# # sudo make
# # UPTO HERE
# #tar xvzf pyqt.tar.gz
# #cd pyqt
# #python configure-ng.py --confirm-license --sip /System/Library/Frameworks/Python.framework/Versions/2.7/bin/sip
# #make # takes a MAD long time
# #sudo make install
# 
# #sudo pip install --upgrade matplotlib
# # sudo pip install pandas
# # sudo pip install pymc
# # sudo pip install scikit-learn
# # sudo pip install statsmodels
# 
# #sudo installer -pkg pyside.pkg -target '/'
# 
# #sudo pip install ipython
# 
# #sudo chown $USER .matplotlib
# 
# # ipython qtconsole works
# 
# # sudo pip install requests
# # sudo pip install argparse
# # sudo pip install dicttoxml
# # sudo pip install pudb
# # sudo pip install datetime
# # sudo pip install freebase
# # sudo pip install networkx
# # sudo pip install pyyaml
# # sudo pip install twitter
# # sudo pip install simplejson
# # 
# # sudo pkgin -y install libxml2
# # 
# # sudo pip install lxml
# 
# #sudo installer -pkg R.pkg -target '/'
# 
# # just dragged rstudio
# 
# #echo 'options(repos=structure(c(CRAN="http://cran.revolutionanalytics.com")))' > ~/.Rprofile
# 
# #chmod +x Rbootstrap.R
# #./Rbootstrap.R
# 
# # REMEMBER YOU HAVE TO INSTALL SIMBLE, ETCC ALL BY YOURSELF
# # DRAG RSTUDIO BY YO SELF
# 
# #sudo pkgin -y install mercurial
# 
# #hg clone https://vim.googlecode.com/hg/ vim
# #cd vim
# #hg pull
# #hg update
# #./configure "CFLAGS=-O3" --prefix=/usr/local --enable-rubyinterp --enable-pythoninterp --enable-perlinterp --with-features=huge --enable-gui=no --without-x --disable-nls --enable-multibyte --with-tlib=ncurses  --with-compiledby=Tony.Fischetti
# #make
# #sudo make install
# 
# #git clone https://github.com/b4winckler/macvim.git
# #cd macvim
# #./configure "CFLAGS=-O3" --with-features=huge --enable-ruby-interp --enable-pythoninterp --enable-perlinterp --enable-cscope  --enable-multibyte --with-tlib=ncurses --with-compiledby=Tony.Fischetti --with-ruby-command=/usr/bin/ruby --with-macarchs=x86_64 --with-macsdk=10.8 --enable-fail-if-missing --disable-netbeans --with-developer-dir=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform
# #make
# #sudo cp -R src/MacVim/build/Release/MacVim.app /Applications
# #sudo cp src/MacVim/mvim /usr/local/bin
# 
# 
# # COP JAVA
# # cop NLTK
