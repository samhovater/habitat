# habitat
habitat manages python environments

## installation
```bash
git clone git@github.com:samhovater/habitat.git
cd habitat
chmod +x install.sh
# local install (adds line to .bashrc)
./install.sh local hab.sh

# system install (moves into /etc/profile.d
sudo ./install.sh system hab.sh
```

## usage
The script assumes your python installs are located in /usr/bin:
```bash
# create it
hab create python3.12 new_env
# activate it (hab has autocomplete)
hab activate new_env
# clone it 
hab clone new_env cloned_env
# see all
hab list
# delete
hab delete cloned_env

# install packages as you normally would
hab activate new_env
python -m pip install pandas
```


