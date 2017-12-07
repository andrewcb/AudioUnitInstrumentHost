# AudioUnitInstrumentHost

This is example/exploratory code for loading and playing AudioUnit instrument plugins on macOS in Swift.

## Usage

The app itself doesn't do all that much, and is mostly useful as a code example. However, you can load and play notes on any AudioUnit software instruments installed on the running machine. Select an instrument from the expandable outline view, and it will be loaded and its GUI presented. Then, with the focus in the selection window, use the keyboard to play notes.

## AudioUnit v2 vs v3

This code implements both the AudioUnit V2 and V3 plugin hosting APIs; these are abstracted in two instances of a protocol, `InstrumentHost`. The `AudioService` class loads one of these, which may be changed there.

While AudioUnit v3 is officially the new way of doing things, there appear to be reliability problems with using this with existing V2 plugins. (These also appear in Apple's `AudioUnitV3Example` code example.)  As such, the default hosting code used is the V2 code, which has been wrapped lightly in Swift.  To change to the v3 API, change the line in `AudioService` which reads 

```
    var host: InstrumentHost = AUv2InstrumentHost()
```

## Authors

 * **Andrew Bulhak** - *initial development* - [GitHub](https://github.com/andrewcb/)/[Technical blog](http://tech.null.org/)

## License

This code is licenced under the MIT License
