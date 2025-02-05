#!/bin/bash
HAB_DIR=~/.hab/envs
BIN_PATH=/usr/bin

prompt_confirm() {
	while true; do
		read -r -n 1 -p "${1:-Continue?} [y/n]:" REPLY
		case $REPLY in 
			[yY]) echo ; return 0 ;;
			[nN]) echo ; return 1 ;;
			*) printf " invalid input" ;;
		esac
	done
}


hab() {
	USAGE="
	Usage: hab <command> [options]
	Available commands:
	  create     - create a new habitat
	  activate - activate an existing habitat
	  delete - delete a habitat
	  list - list all habitats
	  clone - clone an existing habitat to a new one
	
	Options:
	  -h, -help 	show this help message and exit
	
	Examples:
	  hab create python3.11 myhab
	  hab activate myhab
	"
	# manage arguments
	local command=$1
	shift
	case $command in 
	"-h")
	  echo "$USAGE"
	  return
	  ;;
	"--help")
	  echo "$USAGE"
	  return
	  ;;
	create)
	  VERSION=$1
	  NAME=$2
	  _hab_create "$NAME" "$VERSION"
	  ;;
	activate)
	  NAME=$1
	  HPATH="$HAB_DIR/$NAME"
	  if ( ! _hab_exists $NAME ); then
	    echo "habitat $NAME not found!"
	    return
	  fi
	  source "$HPATH/bin/activate"
	  ;;
	delete)
	  NAME=$1
	  HPATH="$HAB_DIR/$NAME"
	  if ( ! _hab_exists $NAME ); then
	    echo "habitat $NAME not found!"
	    return
	  fi
	  if ( prompt_confirm "Are you sure you want to delete habitat $NAME?" ); then
	    echo "Deleting $NAME..."
	    rm -r "$HPATH"
	  fi
	  ;;
	list)
	  _hab_list
	  ;;
	clone)
	  # cloning a venv is non-trivial - the best way is to just reinstall all packages from pip
	  OLDHAB=$1
	  NEWHAB=$2
	  echo "cloning $OLDHAB..."
	  HPATH="$HAB_DIR/$OLDHAB"
	  if ( ! _hab_exists $OLDHAB ); then
	    echo "habitat $OLDHAB not found!"
	    return
	  fi
	  NHPATH="$HAB_DIR/$NEWHAB"
	  if ( _hab_exists $NEWHAB ); then
	    echo "habitat $NEWHAB already exists!"
	    return
	  fi
	  # get the version number
	  VERSION=$(grep -s "version" "$HPATH/pyvenv.cfg" | awk '{print $3}' | cut -d '.' -f 1-2 )
	  old_hab_python="$HPATH/bin/python"
	  new_hab_python="$NHPATH/bin/python"
	
	  _hab_create "$NEWHAB" "python$VERSION"
	  "$old_hab_python" -m pip freeze | xargs "$new_hab_python" -m pip install
	  ;;
	*)
	  echo "Unknown command: $command"; echo "$USAGE"
	  ;;
	esac
}

_hab_create() {
	local NAME=$1
	local VERSION=$2
	local python="$BIN_PATH/$VERSION"
	if [[ ! -e "$python" ]]; then
	  echo "$VERSION not found at $python! Exiting..."
	  return
	fi
	
	if [[ ! -d "$HAB_DIR" ]]; then
	  mkdir -p "$HAB_DIR"
	fi
	
	local HPATH="$HAB_DIR/$NAME"
	$python -m venv --upgrade-deps "$HPATH"
	echo "habitat created at $HPATH!"
	return
}

_hab_exists() {
	local NAME=$1
	local HPATH="$HAB_DIR/$NAME"
	if [[ ! -d "$HPATH" ]]; then
	  return 1 # failure
	else
	  return 0 # success
	fi
}

_hab_list() {
	printf "%-15s | %-10s\n" "NAME" "VERSION"
	printf "%s\n" "-----------------------------------------"
	
	for dir in $HAB_DIR/*; do
	  pyenv_cfg="$dir/pyvenv.cfg"
	  if [[ -f "$pyenv_cfg" ]]; then
	    CURNAME="$(basename $dir)"
	    VERSION=$(grep -s "version" "$pyenv_cfg" | awk '{print $3}')
	    printf "%-15s | %-10s\n" "$CURNAME" "$VERSION"
	  fi
	done
}

_hab_autocomplete() {
	local cur prev prev_prev
	COMPREPLY=()
	cur="${COMP_WORDS[COMP_CWORD]}"
	prev="${COMP_WORDS[COMP_CWORD-1]}"
	if [ $COMP_CWORD -gt 1 ] ; then
	  prev_prev="${COMP_WORDS[COMP_CWORD-2]}"
	fi
	
	local commands="activate clone delete create list"
	local habitats=$(hab list | awk 'NR>2 {print $1}')
	
	if [ $COMP_CWORD -eq 1 ]; then
	  COMPREPLY=( $(compgen -W "$commands" -- "$cur") )
	elif [[ "$prev" =~ ^(activate|clone|delete)$ ]]; then
	  COMPREPLY=( $(compgen -W "$habitats" -- "$cur") )
	fi
}

complete -F _hab_autocomplete hab
