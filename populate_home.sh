#!/bin/bash
dotFiles=`ls -a`
if [ ! -d "$HOME/dot_backup" ]; then
	mkdir $HOME/dot_backup
	for file in ${dotFiles:4}; do
		if [ -e "$HOME/$file" ]; then
			cp -r $HOME/$file $HOME/dot_backup/
		fi
	done
fi
for file in ${dotFiles:4}; do
	if [ "$file" != '.git' ] && [ "$file" != 'populate_home.sh' ] \
		&& [ "$file" != '.ssh' ]; then
		if [ -e "$HOME/$file" ]; then
			`rm -rf $HOME/$file` > /dev/null
		fi
		ln -s $PWD/$file $HOME/ > /dev/null 
		err=$?
		if [ $err == 0 ]; then
			echo "$file put in Home"
		else echo "Trouble with $file"
		fi
	elif [ "$file" == '.ssh' ]; then
		mv $HOME/.ssh/config $HOME/.ssh/config_old
		ln -s $PWD/.ssh/config $HOME/.ssh/config
		err=$?
		if [ $err == 0 ]; then
			echo "$file put in Home"
		else echo "Trouble with $file"
		fi
	fi
done
