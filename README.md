# habitat
habitat manages python environments

This is a simple script that relies on `venv`, `pip`, and a little bit of bash to keep all your environments in a central location. It's not doing anything complicated but has been useful for me in my python adventures.

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

### on clone
> Why does `hab clone` just reinstall all the packages?

"Cloning" a venv (through something like a copy) is non trivial, you actually have to go and modify files within the venv. It's easier to just take all the packages and reinstall them.
