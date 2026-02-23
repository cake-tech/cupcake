// BIP39 test vector seed, also used by BIP84 for its reference addresses.
const bip39TestSeed =
    "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about";

// m/84'/0'/0'/0/0, the BIP84 reference address for [bip39TestSeed].
const bitcoinAddress = "bc1qcr8te4kr609gcawutmrza0j4xv80jy8z306fyu";
const bitcoinXpub =
    "xpub6CatWdiZiodmUeTDp8LT5or8nmbKNcuyvz7WyksVFkKB4RHwCD3XyuvPEbvqAQY3rAPshWcMLoP2fMFMKHPJ4ZeZXYVUhLv1VMrjPC7PW6V";

// Spends a fabricated P2WPKH utxo on m/84'/0'/0'/0/0 to m/84'/0'/0'/0/1.
const bitcoinUnsignedPsbt =
    "cHNidP8BAFICAAAAAR8fKfDomQji4hOuyd1B9daUpObUp0dfOfqS4IyXHEC8AAAAAAD9////AZBfAQAAAAAAFgAUnJD5NOpR+g9lBBdwQ+CQjaaSmYMAAAAAAAEBH6CGAQAAAAAAFgAUwM681sPTyox13F7GLr5VMw75EOIiBgMw1U/Q3UIKbl+NNiT180gsrjUPedXwdTv1vu+cLZGvPBhzxdoKVAAAgAAAAIAAAACAAAAAAAAAAAAAIgID53X9UfDfuM2GXZ/xzKKhWM9lH+mX/cn+6cHTtemV6ncYc8XaClQAAIAAAACAAAAAgAAAAAABAAAAAA==";

// Witness data does not affect the txid, so a correctly signed transaction
// must still commit to exactly the payment that was requested.
const bitcoinExpectedTxid = "0ff7dabd7a9630099aedd328c789150ad087d2751094392027572e3cf94a0ee1";
const bitcoinInputPubkey = "0330d54fd0dd420a6e5f8d3624f5f3482cae350f79d5f0753bf5beef9c2d91af3c";

// Same payment as [bitcoinUnsignedPsbt], but the input requests SIGHASH_NONE.
// A signature produced under that flag commits to no outputs, so an attacker
// can rewrite every recipient after the user confirms the benign-looking tx.
const bitcoinSighashNonePsbt =
    "cHNidP8BAFICAAAAAR8fKfDomQji4hOuyd1B9daUpObUp0dfOfqS4IyXHEC8AAAAAAD9////AZBfAQAAAAAAFgAUnJD5NOpR+g9lBBdwQ+CQjaaSmYMAAAAAAAEBH6CGAQAAAAAAFgAUwM681sPTyox13F7GLr5VMw75EOIiBgMw1U/Q3UIKbl+NNiT180gsrjUPedXwdTv1vu+cLZGvPBhzxdoKVAAAgAAAAIAAAACAAAAAAAAAAAABAwQCAAAAACICA+d1/VHw37jNhl2f8cyioVjPZR/pl/3J/unB07Xplep3GHPF2gpUAACAAAAAgAAAAIAAAAAAAQAAAAA=";

// PSBT v2, two inputs, no global unsigned tx. Only input 2 has SIGHASH_NONE.
const bitcoinV2MultiInputSighashNonePsbt =
    "cHNidP8BAgQCAAAAAQMEAAAAAAEEAQIBBQEBAAEOIKqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqAQ8EAAAAAAEQBP////8AAQ4gu7u7u7u7u7u7u7u7u7u7u7u7u7u7u7u7u7u7u7u7u7sBDwQBAAAAARAE/////wEDBAIAAAAAAQMIUMMAAAAAAAABBBYAFAAAAAAAAAAAAAAAAAAAAAAAAAAAAA==";

// Shape of a normal Cake Wallet -> Cupcake Bitcoin PSBT after asPsbtV0:
// NON_WITNESS_UTXO + WITNESS_UTXO, BIP32 derivation, no SIGHASH_TYPE.
const bitcoinCakeWalletUnsignedPsbt =
    "cHNidP8BAFICAAAAAaqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqAAAAAAABAAAAAZBfAQAAAAAAFgAUREREREREREREREREREREREREREQAAAAAAAEAUgIAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD/////AP////8BoIYBAAAAAAAWABQzMzMzMzMzMzMzMzMzMzMzMzMzMwAAAAABAR6ghgEAAAAAAAAUMzMzMzMzMzMzMzMzMzMzMzMzMzMiBgJVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVRjerb7vVAAAgAAAAIAAAACAAAAAAAAAAAAAAA==";

/// m/84'/2'/0'/0/0 for [bip39TestSeed].
const litecoinAddress = "ltc1qjmxnz78nmc8nq77wuxh25n2es7rzm5c2rkk4wh";

// Must be a version 2 psbt: mwebd reads the recipients and rebuilds the
// transaction from the per input and per output fields, and ignores the
// unsigned transaction that a version 0 psbt carries in its global map.
const litecoinUnsignedPsbt =
    "cHNidP8B+wQCAAAAAQIEAgAAAAEDBAAAAAABBAEBAQUBAQGSAQAAAQEfoIYBAAAAAAAWABSWzTF4894PMHvO4a6qTVmHhi3TCiIGAuScm5tdDxJyNdwmoMJSgUxS+zM9ZRqUZ3P1nXLC2pkEGHPF2gpUAACAAgAAgAAAAIAAAAAAAAAAAAEOIBwQp2anNzcJldK5tGtLqj6Rzl+YnOe58+WT3PIRPwSQAQ8EAAAAAAEQBP3///8AIgICHBdQ1KWtVDlnsw6UR+UNp6WHPovhM+sl8s4OpWOLnRcYc8XaClQAAIACAACAAAAAgAAAAAABAAAAAQMIkF8BAAAAAAABBBYAFHfyII4nK++A6YzpVuBdXtj1lvWjAA==";

const litecoinExpectedTxid = "d94e56263979b4ec61784d8a7d33d9bc03801d6dbb2a91a821a17e0d70c4ffc9";
const litecoinInputPubkey = "02e49c9b9b5d0f127235dc26a0c252814c52fb333d651a946773f59d72c2da9904";
const litecoinDestination = "ltc1qwlezpr3890hcp6vva9twqh27mr6edadreqvhnn";
const litecoinDestinationAmount = 90000;
const litecoinFee = 10000;

// The 25 word seed from monero's own cold signing functional test.
const moneroLegacySeed =
    "velvet lymph giddy number token physics poetry unquoted nibs useful sabotage "
    "limits benches lifestyle eden nitrogen anvil fewest avoid batch vials washing "
    "fences goat unquoted";
const moneroLegacyAddress =
    "42ey1afDFnn4886T7196doS9GPMzexD9gXpsZJDwVjeRVdFCSoHnv7KPbBeGpzJBzHRCAs9UxqeoyFQMYbqSWYTfJJQAWDm";

// Polyseed wallet the signing fixtures below were captured from.
const moneroPolyseed =
    "dentist never novel grain this patient globe extra deputy celery fossil mansion soft long sustain second";
const moneroPolyseedAddress =
    "434dZdLzhymcoNyGSBUJAqhDCLtBECN6698CGRMYByuEAYtpxXdbiibQb3t4qX3SiZi9vDWkxeiEF8kmDGmEoEZ4VMG8Nvh";

// Captured from a view-only wallet of [moneroPolyseed] with:
//   monero-wallet-rpc export_outputs  -> outputs_data_hex
//   monero-wallet-rpc transfer        -> unsigned_txset
// then hex decoded and stored base64. The cold signer wraps them back into a
// UR at runtime, which is byte for byte what a QR scan would have produced.
const moneroOutputsBase64 =
    "TW9uZXJvIG91dHB1dCBleHBvcnQE9fEp/6bf/wEHJu5LlCaq9fKL7DgC4LEZaSxbn+RMKd7rki35tMtvFN416eIkouD0MaLsl/v9MRXEhvgvHbKnIdzmNmelmdCUV/zdmGNRF06siP1JhF9UtofVZl6PLF9TrSyEH4YgHuWZyy3DGDTk13FQZq0skluBdciKOd9lyVs7sJRaw0keUx0DCfZs2lrYl8EwEOoxPiZ3ZcXtUL9SuOpdOTg8CBxTyawB1emZwXKD2vFyQOusNOkb5tw17kHQivgVf/zZa0OBzh74Wwv3YCZ3kfQ0T3kQjr3GqdcN4XsG7wxZVW0U17pXLsQQgBIk7Dg2iTOyTmIktb0P9oFQljfGrbIzMqFhmRfbmyFraCC/8LLX4mqXH6b1uShx2UCDrm2JaEavbatXRcGEamUno8PWdpUTfI/7T4DAhhodjJU4iVwxEtbRrc6lCqmAY/crq5LvDQexBI8BW8+bz1KzGVo+LQinv9mNBAa1jcBWVrbkbwgyZfQN5wU=";

const moneroUnsignedTxBase64 =
    "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";

// Destination and amounts of the prepared transaction, as the signer must
// display them before asking for confirmation. It is a self transfer, so the
// destination is the wallet's own primary address.
const moneroDestination = moneroPolyseedAddress;
const moneroAmount = 100000000;
const moneroFee = 122960000;
