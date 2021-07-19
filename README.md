# DemonOS

## Build

```
$ ./build.sh
```

## RUN

```
$ qemu-system-x86_64 -hda ./bin/os.bin
```

## GDB RUN

```
$ target remote | qemu-system-x86_64 -S -gdb stdio -hda ./os.bin
```
