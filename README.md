# pratipad_example_device

This repository provides an example device implementation using [pratipad_client](https://github.com/kentaro/pratipad_client).

The device is supposed to be able to utilize both BME280 and MH-Z19 sensors. The data retrieved from them are sent to a dataflow implemented by [pratipad](https://github.com/kentaro/pratipad)

## Deployment

Initial deployment to the SD card locally installed:

```sh
$ PRATIPAD_DEVICE=device1 mix firmware.burn
```

Remote deployment to the device directly via LAN:

```sh
$ PRATIPAD_DEVICE=device1 mix firmware
$ ./upload.sh device1.local
```

## Author

Kentaro Kuribayashi
