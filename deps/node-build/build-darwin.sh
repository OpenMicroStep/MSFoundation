set -e
pushd ../node

LIBPATH=`pwd`/../node-build/x86_64-darwin
mkdir -p $LIBPATH/debug $LIBPATH/release
cp ../../out/openmicrostep-foundation-x86_64-darwin/framework/MSFoundation.framework/MSFoundation ../node-build/x86_64-darwin/libMSFoundation.dylib
./configure --debug --dest-cpu=x64 --shared-libuv --shared-libuv-include=../libuv/include --shared-libuv-libpath=$LIBPATH --shared-libuv-libname=MSFoundation
make -j 6
pushd out/Debug
cp libnode.dylib $LIBPATH/debug
popd
pushd out/Release
cp libnode.dylib $LIBPATH/release
popd
rm ../node-build/x86_64-darwin/libMSFoundation.dylib
#make clean

# Node on doesn't build i386 darwin :(
# LIBPATH=`pwd`/../node-build/i386-darwin
# mkdir -p $LIBPATH/debug $LIBPATH/release
# cp ../../out/openmicrostep-foundation-i386-darwin/framework/MSFoundation.framework/MSFoundation ../node-build/i386-darwin/libMSFoundation.dylib
# ./configure --debug --dest-cpu=ia32 --shared-libuv --shared-libuv-include=../libuv/include --shared-libuv-libpath=$LIBPATH --shared-libuv-libname=MSFoundation
# make -j 6
# pushd out/Debug
# cp libopenssl.a libchrome_zlib.a libhttp_parser.a libcares.a libv8_base.a libv8_libbase.a libv8_snapshot.a libnode.a libdebugger-agent.a $LIBPATH/debug
# popd
# pushd out/Release
# cp libopenssl.a libchrome_zlib.a libhttp_parser.a libcares.a libv8_base.a libv8_libbase.a libv8_snapshot.a libnode.a libdebugger-agent.a $LIBPATH/release
# popd
# rm ../node-build/i386-darwin/libMSFoundation.dylib
# make clean

popd
