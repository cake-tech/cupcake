include .env
UNAME := $(shell uname)

libs_android_download:
	./build_moneroc.sh --prebuild --coin ${COIN} --tag ${MONERO_C_TAG} --triplet x86_64-linux-android  --location android/app/src/main/jniLibs/x86_64
	./build_moneroc.sh --prebuild --coin ${COIN} --tag ${MONERO_C_TAG} --triplet aarch64-linux-android --location android/app/src/main/jniLibs/arm64-v8a
	./build_moneroc.sh --prebuild --coin ${COIN} --tag ${MONERO_C_TAG} --triplet armv7a-linux-androideabi --location android/app/src/main/jniLibs/armeabi-v7a

libs_android_build:
ifneq ($(UNAME), Linux)
	echo Only Linux hosts can build for android, try $(MAKE) libs_android_download
	exit 1
endif
	./build_moneroc.sh --coin ${COIN} --tag ${MONERO_C_TAG} --triplet x86_64-linux-android  --location android/app/src/main/jniLibs/x86_64
	./build_moneroc.sh --coin ${COIN} --tag ${MONERO_C_TAG} --triplet aarch64-linux-android --location android/app/src/main/jniLibs/arm64-v8a
	./build_moneroc.sh --coin ${COIN} --tag ${MONERO_C_TAG} --triplet armv7a-linux-androideabi --location android/app/src/main/jniLibs/armeabi-v7a

libs_android_build_ci:
	./build_moneroc.sh --coin ${COIN} --tag ${MONERO_C_TAG} --triplet aarch64-linux-android --location android/app/src/main/jniLibs/arm64-v8a

libs_ios_download:
	./build_moneroc.sh --prebuild --coin ${COIN} --tag ${MONERO_C_TAG} --triplet aarch64-apple-ios --location ios/native_libs/ios-arm64
	./build_moneroc.sh --prebuild --coin ${COIN} --tag ${MONERO_C_TAG} --triplet aarch64-apple-iossimulator --location ios/native_libs/ios-arm64-simulator
	cd ios && ./gen_framework.sh

libs_ios_build:
ifneq ($(UNAME), Darwin)
	echo Only Darwin hosts can build for iOS, try $(MAKE) libs_ios_download
	exit 1
endif
	./build_moneroc.sh --coin ${COIN} --tag ${MONERO_C_TAG} --triplet aarch64-apple-ios --location ios/native_libs/ios-arm64
	./build_moneroc.sh --coin ${COIN} --tag ${MONERO_C_TAG} --triplet aarch64-apple-iossimulator --location ios/native_libs/ios-arm64-simulator
	cd ios && ./gen_framework.sh

cupcake_android_monero:
	dart run build_runner build --delete-conflicting-outputs
	flutter build apk --dart-define=COIN_MONERO=true

cupcake_ios_monero:
	dart run build_runner build --delete-conflicting-outputs
	flutter build ios --no-codesign --dart-define=COIN_MONERO=true

prepare_dev:
	./.tooling/prepare_dev.sh