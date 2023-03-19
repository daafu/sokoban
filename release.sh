jai-linux src/build.jai -release -exe piotr -output_path ..

mkdir -p deploy/linux
cp  piotr deploy/linux
cp -r res deploy/linux
