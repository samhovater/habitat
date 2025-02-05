USAGE="
Usage: $0 [system|local] /path/to/hab.sh
  system - install must be run as sudo!
  local - install will add a line to your .bashrc!
"

if [[ $# -ne 2 ]]; then
	echo "incorrect arguments!"
	echo "$USAGE"
	exit 1
fi

MODE=$1
HABPATH=$(realpath "$2")
FILENAME=$(basename "$HABPATH")
echo $FILENAME
case $MODE in
  system)
    echo "Copying hab file to /etc/profile.d/hab.sh"
    cp -f $HABPATH /etc/profile.d/hab.sh
    chmod 644 /etc/profile.d/hab.sh
    ;;
  local)
    echo "adding line to .bashrc"
    echo -e "### added by habitat ###\nsource $HABPATH \n###" >> ~/.bashrc
    ;;
  *)
    echo "Invalid mode"
    echo "$USAGE"
    exit 1
    ;;
esac
