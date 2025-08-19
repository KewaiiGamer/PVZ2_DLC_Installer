#!/bin/bash
echo "You have to download PVZ DLC Edition manually before processing"
echo "If this script does not open the url by itself here is the link: https://gamejolt.com/games/pvzdlceditionmod/1009738"
read -p "Press enter to attempt open the url in browser"
xdg-open "https://gamejolt.com/games/pvzdlceditionmod/1009738"
read -p "PRess enter to continue"
pvz2_dlc_zip=$(kdialog --title "Select zip file for PVZ2 DLC Edition" --getopenfilename . 'application/zip' 2>/dev/null)
pvz2_dlc_folder=$(kdialog --title "Select folder to install PVZ2 DLC Edition (should be empty)" --getexistingdirectory . 2>/dev/null)
#steamapps=$(find ~ ! -readable -prune -o -name 'steamapps'  -print  | grep -v compatdata | grep -v "Trash" | grep -v 'drive_[a-z]')
libraryfolders=$(find ~ ! -readable -prune -o -name 'libraryfolders.vdf'  -print | grep -v 'compatdata' | grep -v 'Trash' | grep -v 'drive_[a-z]' | grep config)
echo "Found libraryfolders.vdf at $libraryfolders"
libraries=$(cat $libraryfolders | grep path | xargs -n 2 | cut -d ' ' -f2)
for i in "${libraries[@]}"
do
  executable=$(find $i -name PlantsVsZombies.exe)
done
echo "Found PVZ2 Executable at path $executable"
xdelta3_exists=$(pacman -Ss xdelta3 | grep installed)
if [ -z "$xdelta3_exists" ];  then
   echo "xdelta3 package is not installed. trying to install"
   sudo pacman -S xdelta3
fi
echo "Creating PVZ2 DLC Edition Installation folder in case it does not exist"
mkdir -p "$pvz2_dlc_folder" 2>/dev/null
echo "Copying PlantsVsZombies.exe to DLC Edition folder"
sudo cp -r "$executable" "$pvz2_dlc_folder"
echo "Extracting PVZ2 DLC Edition zip file..."
unzip -qq "$pvz2_dlc_zip" -d "$pvz2_dlc_folder"
echo "Extraction completed"
cd "$pvz2_dlc_folder"
echo "Patching PlantsVsZombies.exe with 'Patch Steam.xdelta'"
xdelta3 -f PlantsVsZombies.exe "Patch Steam.xdelta"
echo "Patching Completed"
echo "If the game shows black screen try to press CTRL+Enter to enter fullscreen."
read -p "Do you want the script to add the Game to your steam library as a Non Steam App using https://github.com/sonic2kk/steamtinkerlaunch automatically (Default: Y)" -n 1 -r
if [[ $REPLY  =~ ^[Yy]$ || -z $REPLY ]]
then
   pkill steam
   git clone https://github.com/KewaiiGamer/steam-conductor.git
   cd steam-conductor
   python3 -m venv .venv
   source .venv/bin/activate
   pip3 install -e .
   read -p "Enter the app name to show on steam. If nothing typed 'Plants Vs Zombies (DLC Edition)' will be used" appName
   read -p "Enter the compatibilitytool. If nothing typed 'proton_9' will be used (Recommended: proton_9) (Default: proton_9)" compatTool
   compatTool=${compatTool:-proton_9}
   appName=${appName:-"Plants Vs Zombies (DLC Edition)"}
   python3 ./src/conductor/cli/ add_shortcut --app-name="$appName" --exe-path="$pvz2_dlc_folder/PlantsVsZombies.exe" --compat-tool="$compatTool"
   cd ..
   rm -rf steam-conductor
fi


