include .env
UNAME := $(shell uname)

libs_android_download: mwebd_android
	./build_moneroc.sh --prebuild --coin ${COIN} --tag ${MONERO_C_TAG} --triplet x86_64-linux-android  --location android/app/src/main/jniLibs/x86_64
	./build_moneroc.sh --prebuild --coin ${COIN} --tag ${MONERO_C_TAG} --triplet aarch64-linux-android --location android/app/src/main/jniLibs/arm64-v8a
	./build_moneroc.sh --prebuild --coin ${COIN} --tag ${MONERO_C_TAG} --triplet armv7a-linux-androideabi --location android/app/src/main/jniLibs/armeabi-v7a

libs_android_build: mwebd_android
ifneq ($(UNAME), Linux)
	echo Only Linux hosts can build for android, try $(MAKE) libs_android_download
	exit 1
endif
	./build_moneroc.sh --coin ${COIN} --tag ${MONERO_C_TAG} --triplet x86_64-linux-android  --location android/app/src/main/jniLibs/x86_64
	./build_moneroc.sh --coin ${COIN} --tag ${MONERO_C_TAG} --triplet aarch64-linux-android --location android/app/src/main/jniLibs/arm64-v8a
	./build_moneroc.sh --coin ${COIN} --tag ${MONERO_C_TAG} --triplet armv7a-linux-androideabi --location android/app/src/main/jniLibs/armeabi-v7a

libs_android_build_ci: mwebd_android
	./build_moneroc.sh --coin ${COIN} --tag ${MONERO_C_TAG} --triplet aarch64-linux-android --location android/app/src/main/jniLibs/arm64-v8a

libs_ios_download: mwebd_ios
	./build_moneroc.sh --prebuild --coin ${COIN} --tag ${MONERO_C_TAG} --triplet aarch64-apple-ios --location ios/native_libs/ios-arm64
	./build_moneroc.sh --prebuild --coin ${COIN} --tag ${MONERO_C_TAG} --triplet aarch64-apple-iossimulator --location ios/native_libs/ios-arm64-simulator
	cd ios && ./gen_framework.sh

libs_ios_build: mwebd_ios
ifneq ($(UNAME), Darwin)
	echo Only Darwin hosts can build for iOS, try $(MAKE) libs_ios_download
	exit 1
endif
	./build_moneroc.sh --coin ${COIN} --tag ${MONERO_C_TAG} --triplet aarch64-apple-ios --location ios/native_libs/ios-arm64
	./build_moneroc.sh --coin ${COIN} --tag ${MONERO_C_TAG} --triplet aarch64-apple-iossimulator --location ios/native_libs/ios-arm64-simulator
	cd ios && ./gen_framework.sh

cupcake_android:
	flutter build apk

cupcake_ios:
	flutter build ios --no-codesign

mwebd_android:
	cd external/cake_wallet/scripts/android && bash ./build_mwebd.sh --dont-install
	
mwebd_ios:
	cd external/cake_wallet/scripts/ios && bash ./build_mwebd.sh --dont-install

prepare_dev:
	cd external/cake_wallet/scripts && bash ./prepare_torch.sh
	./.tooling/prepare_dev.sh