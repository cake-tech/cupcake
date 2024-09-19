include .env

libs_android_download:
	./build_moneroc.sh --prebuild --coin ${COIN} --tag ${MONERO_C_TAG} --triplet x86_64-linux-android  --location android/app/src/main/jniLibs/x86_64
	./build_moneroc.sh --prebuild --coin ${COIN} --tag ${MONERO_C_TAG} --triplet aarch64-linux-android --location android/app/src/main/jniLibs/arm64-v8a
	./build_moneroc.sh --prebuild --coin ${COIN} --tag ${MONERO_C_TAG} --triplet armv7a-linux-androideabi --location android/app/src/main/jniLibs/armeabi-v7a

libs_android_build:
	[[ ! "x$(shell uname)" == "xLinux" ]] && exit 1 # Only Linux hosts can build for android, try $(MAKE) libs_android_download
	./build_moneroc.sh --coin ${COIN} --tag ${MONERO_C_TAG} --triplet x86_64-linux-android  --location android/app/src/main/jniLibs/x86_64
	./build_moneroc.sh --coin ${COIN} --tag ${MONERO_C_TAG} --triplet aarch64-linux-android --location android/app/src/main/jniLibs/arm64-v8a
	./build_moneroc.sh --coin ${COIN} --tag ${MONERO_C_TAG} --triplet armv7a-linux-androideabi --location android/app/src/main/jniLibs/armeabi-v7a

libs_android_build_ci:
	./build_moneroc.sh --coin ${COIN} --tag ${MONERO_C_TAG} --triplet aarch64-linux-android --location android/app/src/main/jniLibs/arm64-v8a

libs_ios_download:
	./build_moneroc.sh --prebuild --coin ${COIN} --tag ${MONERO_C_TAG} --triplet host-apple-ios --location ios
	cd ios && ./gen_framework.sh
libs_ios_build:
	[[ "x$(shell uname)" == "xDarwin" ]] || exit 1 # Only Darwin hosts can build for iOS, try $(MAKE) libs_ios_download
	./build_moneroc.sh --coin ${COIN} --tag ${MONERO_C_TAG} --triplet host-apple-ios --location ios
	cd ios && ./gen_framework.sh

cupcake_android_monero:
	flutter build apk --dart-define=COIN_MONERO=true
