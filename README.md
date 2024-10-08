# cup_cake

> It's almost cake, but in a cup.


## Getting Started (for developers)

To build:

```bash
$ make libs_android_build # or libs_android_download
$ make cupcake_monero
```

### Adding other coins

This project currently only supports Monero, but is very welcoming of other wallets making it's way to the project.

Adding new wallet is as simple as creating new `<coin>.dart` file in `coins` directory, and adding it to the `coins/list.dart`, with proper configuration options set.

Building flavors of the app is as simple as providing `--dart-define=COIN_MONERO=false`, to disable Monero and doing exactly the same for newly added coin, to enable it.

### Adding assets

```bash
$ dart run build_runner build
$ flutter gen-l10n
```