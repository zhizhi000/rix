reset
echo -e "\e[5m\e[33m>Is this a debug [ y / n ]?\e[0m"
read d
echo -e "\e[1m\e[32m[OK]\e[0m"
echo " "
echo " "
bash clr.sh
echo -e "\e[1m\e[32m[OK]\e[0m"
echo " "
bash comp.sh
echo -e "\e[1m\e[32m[OK]\e[0m"
echo " "
echo -----------------------------------------------------------------
echo -e "\e[1m\e[32mCompiling Ritchie Compiler\e[0m"
echo " "
echo -e "\e[1m\e[32m[OK]\e[0m"
echo -----------------------------------------------------------------

#gcc -W -Wall -pedantic -std=c99 ObjectTree.c ritchie.tab.c lex.yy.c ritc.c errors.c -lfl -o ritc
gcc ObjectTree.c ritchie.tab.c lex.yy.c ritc.c errors.c -lfl -o ritc

if [ -f ritc ]
	then
		echo " "
		echo -e "\e[5m\e[33m>Ritchie File to Compile\e[0m"
		find . -type f -name "*.rit"
		echo -e "\e[32m"
		read file
		echo -e "\e[0m"
		if [ "$d" = "y" ]
			then 
				./ritc -t $file
			else
				./ritc $file
		fi
		if [ -f out.c ]
			then
				echo " "
				echo -e "\e[1m\e[32m[OK]\e[0m"
				echo ""								
				gcc out.c -lm
				if [ -f a.out ]
					then
						echo -e "\e[33mRun executable [ y / n ]?\e[0m"
						read in
						if [ "$in" = "y" ]
							then
								echo ""
								echo -e "\e[1m\e[32m[OK]\e[0m"
								if [ "$d" = "y" ]
									then
										echo " "
										echo -e "\e[1mRunning Debug \e[0m"
										echo ""
										./a.out -t
										echo ""
										echo -e "\e[1m\e[32m[Done]\e[0m"
									else
										echo " "
										echo -e "\e[1mRunning Normal \e[0m"
										echo ""
										./a.out
										echo ""
										echo -e "\e[1m\e[32m[Done]\e[0m"
										echo " "
								fi
								
						fi
				fi
		fi
fi

