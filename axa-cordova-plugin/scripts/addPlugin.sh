#!/bin/sh
# This script will overwrite the default AppDelegate.mgs



usage()
{

echo Error : "$1"
cat << EOF

Set build options in AppDelegateOptions

EOF

exit -1;
}




res=''
res=$(pwd | egrep '/scripts')

if [ -z "$res" ];  then
	usage  "This script should be called by the Cordova hook!"
fi

cd ../
PLUGIN_DIR=$PWD/
PROJECT_DIR=''

if [ -z "$1" ]; then
	usage "You must provide the location of your cordova app"
fi

PROJECT_DIR=$1
echo "Installing $PLUGIN_DIR into $PROJECT_DIR"

# Check if they actually added a plist
theDiff=$(cat ./cordova_camdo.plist)

if [ -z "$theDiff" ]; then
	usage "Error : You need a cordova_camdo.plist!!"
fi	




theDate=`date +%Y-%m-%d`
theYear=`date +%Y`
name=$(cat AppDelegateOptions | egrep -o '___FULLUSER.*=.*' | egrep -o '=.*' | egrep -o '[^=]+')
organizationName=$(cat AppDelegateOptions | egrep -o '___ORGANIZ.*=.*' | egrep -o '=.*' | egrep -o '[^=]+')
options=$(cat AppDelegateOptions | egrep -o '___OPTIONS.*=.*' | egrep -o '=.*' | egrep -o '[^=]+')


echo "Inserting $theDate $theYear $name $organizationName $options into AppDelegate"


cp AppDelegate.m.axa AppDelegate.m

sed "s/___DATE___/$theDate/" AppDelegate.m |
sed "s/___FULLUSERNAME__/$name/"  |
sed "s/___ORGANIZATIONNAME___/$organizationName/" |
sed "s/___YEAR___/$theYear/" |
sed "s/___OPTIONS___/$options/"  > tmp


cp tmp AppDelegate.m
rm tmp


cd $PROJECT_DIR



appDelegate=''
appDelegate=$(find $PWD  -name "AppDelegate.m" -print | grep "platforms.*AppDelegate.m")
if [ -z "$appDelegate" ]; then
    echo "Could not find the AppDelegate to inject library code, check to make sure you have the iOS platform installed"
    cd $PROJECT_DIR
    cordova plugin remove CAMAA
    exit -1;
fi
echo "Injecting code into $appDelegate"


cd $PLUGIN_DIR
cp AppDelegate.m $appDelegate
rm AppDelegate.m