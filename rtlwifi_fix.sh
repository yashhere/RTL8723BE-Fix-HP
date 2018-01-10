echo ""
echo ""
echo " ____ _____ _ __        _____ _____ ___ "
echo "|  _ \_   _| |\ \      / /_ _|  ___|_ _|"
echo "| |_) || | | | \ \ /\ / / | || |_   | | "
echo "|  _ < | | | |__\ V  V /  | ||  _|  | | "
echo "|_| \_\|_| |_____\_/\_/  |___|_|   |___|"

echo " ___ _   _ ____ _____  _    _     _     "
echo "|_ _| \ | / ___|_   _|/ \  | |   | |    "
echo " | ||  \| \___ \ | | / _ \ | |   | |    "
echo " | || |\  |___) || |/ ___ \| |___| |___ "
echo "|___|_| \_|____/ |_/_/   \_\_____|_____|"
echo ""
echo ""

PACKAGES="gcc g++ build-essential dkms git linux-headers-$(uname -r)"

for pkg in $PACKAGES; do
    dpkg -s $pkg &> /dev/null
    if [ $? -ne 0 ]; then
        echo "Installing $pkg"
        sudo apt install $pkg
    fi
done

RTL_SRC="https://github.com/lwfinger/rtlwifi_new"
LOCAL_REPO="WiFi-Driver"

LOCAL_REPO_VC_DIR=$LOCAL_REPO/.git

if [ ! -d $LOCAL_REPO_VC_DIR ]
then
    echo "Cloning the RTLWiFi drivers from GitHub"
    git clone $RTL_SRC $LOCAL_REPO
else
    echo "Pulling latest changes into existing repository"
    cd $LOCAL_REPO
    git pull $RTL_SRC
    cd ..
fi

cd $LOCAL_REPO
echo "Installing the driver"
make
sudo make install
echo "Removing existing module"
sudo modprobe -r rtl8723be
echo "Changing the antenna position to 2, If it doesn't work, changed ant_sel to 1 in the script."
sudo modprobe rtl8723be ant_sel=2
echo "Making the changes permanent"
echo "options rtl8723be ant_sel=2 fwlps=0" | sudo tee /etc/modprobe.d/rtl8723be.conf
echo "Restarting the driver"
sudo modprobe rtl8723be
