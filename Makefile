CC=clang
CFLAGS=-framework Foundation -framework AVFoundation -framework CoreMediaIO -framework CoreAudio

onair: onair.m
	$(CC) $(CFLAGS) onair.m -o onair
