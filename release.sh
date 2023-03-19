jai-linux src/build.jai -release -exe piotr -output_path ..

rm -rf deploy/linux
mkdir -p deploy/linux
cp  piotr deploy/linux
cp -r res deploy/linux
