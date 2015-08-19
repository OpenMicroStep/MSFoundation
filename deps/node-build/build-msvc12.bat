echo "Those commands must be run in VS2012 x86 native tools"
set i386msvc12=C:\Users\Logitud\Documents\node\i386-msvc12\MSFoundation.lib
python configure --debug --dest-cpu=ia32 --shared-libuv --shared-libuv-include=deps/uv/include --shared-libuv-libpath=%i386msvc12% --without-perfctr --without-etw
msbuild node.sln /m /t:Build /p:Configuration=Debug /clp:NoSummary;NoItemAndPropertyList;Verbosity=minimal /nologo

python configure --dest-cpu=ia32 --shared-libuv --shared-libuv-include=deps/uv/include --shared-libuv-libpath=%i386msvc12% --without-perfctr --without-etw
msbuild node.sln /m /t:Build /p:Configuration=Release /clp:NoSummary;NoItemAndPropertyList;Verbosity=minimal /nologo
echo "Done"


echo "Those commands must be run in VS2012 x64 cross-compile tools"
set x8664msvc12=C:\Users\Logitud\Documents\node\x86_64-msvc12\MSFoundation.lib

python configure --debug --dest-cpu=x64 --shared-libuv --shared-libuv-include=deps/uv/include --shared-libuv-libpath=%x8664msvc12% --without-perfctr --without-etw
msbuild node.sln /m /t:Build /p:Configuration=Debug /clp:NoSummary;NoItemAndPropertyList;Verbosity=minimal /nologo

python configure --dest-cpu=x64 --shared-libuv --shared-libuv-include=deps/uv/include --shared-libuv-libpath=%x8664msvc12% --without-perfctr --without-etw
msbuild node.sln /m /t:Build /p:Configuration=Release /clp:NoSummary;NoItemAndPropertyList;Verbosity=minimal /nologo