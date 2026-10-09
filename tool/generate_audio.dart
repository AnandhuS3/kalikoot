import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

void main() {
  final outDir = Directory('assets/audio');
  if (!outDir.existsSync()) {
    outDir.createSync(recursive: true);
  }

  // 1. tap.wav: Snappy wooden bubble pop
  final tapBytes = generateWav(
    durationSec: 0.08,
    generator: (t, dur) {
      final env = math.exp(-t * 60);
      final freq = 850.0 - (t / dur) * 450.0;
      return math.sin(2 * math.pi * freq * t) * env;
    },
  );
  File('assets/audio/tap.wav').writeAsBytesSync(tapBytes);

  // 2. hit.wav: Heavy pot smash & festive thud
  final hitBytes = generateWav(
    durationSec: 0.35,
    generator: (t, dur) {
      final env = math.exp(-t * 14);
      final bass = math.sin(2 * math.pi * (140.0 - t * 180) * t);
      final mid = math.sin(2 * math.pi * 320.0 * t) * 0.4;
      final noise = (math.Random().nextDouble() * 2 - 1) * math.exp(-t * 40) * 0.5;
      return (bass + mid + noise).clamp(-1.0, 1.0) * env;
    },
  );
  File('assets/audio/hit.wav').writeAsBytesSync(hitBytes);

  // 3. miss.wav: Cartoon descending slide/whoosh
  final missBytes = generateWav(
    durationSec: 0.28,
    generator: (t, dur) {
      final env = math.sin((t / dur) * math.pi);
      final freq = 550.0 - (t / dur) * 350.0;
      return math.sin(2 * math.pi * freq * t) * env * 0.8;
    },
  );
  File('assets/audio/miss.wav').writeAsBytesSync(missBytes);

  // 4. marble.wav: Crisp glass marble clack
  final marbleBytes = generateWav(
    durationSec: 0.12,
    generator: (t, dur) {
      final env = math.exp(-t * 55);
      final tone1 = math.sin(2 * math.pi * 2100.0 * t);
      final tone2 = math.sin(2 * math.pi * 3350.0 * t) * 0.5;
      return (tone1 + tone2) * env * 0.9;
    },
  );
  File('assets/audio/marble.wav').writeAsBytesSync(marbleBytes);

  // 5. clash.wav: Sword clash with metallic ring
  final clashBytes = generateWav(
    durationSec: 0.38,
    generator: (t, dur) {
      final env = math.exp(-t * 12);
      final metallic1 = math.sin(2 * math.pi * 1450.0 * t);
      final metallic2 = math.sin(2 * math.pi * 2200.0 * t) * 0.6;
      final spark = (math.Random().nextDouble() * 2 - 1) * math.exp(-t * 50) * 0.7;
      return (metallic1 + metallic2 + spark).clamp(-1.0, 1.0) * env;
    },
  );
  File('assets/audio/clash.wav').writeAsBytesSync(clashBytes);

  // 6. victory.wav: Celebratory 4-note victory fanfare (C5, E5, G5, C6)
  final victoryBytes = generateWav(
    durationSec: 0.9,
    generator: (t, dur) {
      final notes = [523.25, 659.25, 783.99, 1046.50];
      final noteDur = dur / 4;
      final noteIdx = (t / noteDur).floor().clamp(0, 3);
      final noteT = t - (noteIdx * noteDur);
      final env = math.exp(-noteT * 5) * (noteIdx == 3 ? 1.2 : 0.9);
      final freq = notes[noteIdx];
      final tone = math.sin(2 * math.pi * freq * noteT) +
          0.3 * math.sin(4 * math.pi * freq * noteT);
      return tone * env * 0.7;
    },
  );
  File('assets/audio/victory.wav').writeAsBytesSync(victoryBytes);

  // 7. complete.wav: Cheerful two-tone chime
  final completeBytes = generateWav(
    durationSec: 0.45,
    generator: (t, dur) {
      final noteDur = dur / 2;
      final noteIdx = (t / noteDur).floor().clamp(0, 1);
      final noteT = t - (noteIdx * noteDur);
      final freq = noteIdx == 0 ? 783.99 : 1046.50; // G5 then C6
      final env = math.exp(-noteT * 7);
      return math.sin(2 * math.pi * freq * noteT) * env * 0.8;
    },
  );
  File('assets/audio/complete.wav').writeAsBytesSync(completeBytes);

  print('Audio files generated successfully in assets/audio!');
}

Uint8List generateWav({
  required double durationSec,
  required double Function(double t, double duration) generator,
  int sampleRate = 44100,
}) {
  final numSamples = (durationSec * sampleRate).toInt();
  final numChannels = 1;
  final bitsPerSample = 16;
  final byteRate = sampleRate * numChannels * (bitsPerSample ~/ 8);
  final blockAlign = numChannels * (bitsPerSample ~/ 8);
  final dataSize = numSamples * blockAlign;
  final chunkSize = 36 + dataSize;

  final buffer = ByteData(44 + dataSize);

  // RIFF header
  buffer.setUint8(0, 0x52); // 'R'
  buffer.setUint8(1, 0x49); // 'I'
  buffer.setUint8(2, 0x46); // 'F'
  buffer.setUint8(3, 0x46); // 'F'
  buffer.setUint32(4, chunkSize, Endian.little);
  buffer.setUint8(8, 0x57);  // 'W'
  buffer.setUint8(9, 0x41);  // 'A'
  buffer.setUint8(10, 0x56); // 'V'
  buffer.setUint8(11, 0x45); // 'E'

  // fmt subchunk
  buffer.setUint8(12, 0x66); // 'f'
  buffer.setUint8(13, 0x6D); // 'm'
  buffer.setUint8(14, 0x74); // 't'
  buffer.setUint8(15, 0x20); // ' '
  buffer.setUint32(16, 16, Endian.little); // Subchunk1Size
  buffer.setUint16(20, 1, Endian.little);  // PCM format
  buffer.setUint16(22, numChannels, Endian.little);
  buffer.setUint32(24, sampleRate, Endian.little);
  buffer.setUint32(28, byteRate, Endian.little);
  buffer.setUint16(32, blockAlign, Endian.little);
  buffer.setUint16(34, bitsPerSample, Endian.little);

  // data subchunk
  buffer.setUint8(36, 0x64); // 'd'
  buffer.setUint8(37, 0x61); // 'a'
  buffer.setUint8(38, 0x74); // 't'
  buffer.setUint8(39, 0x61); // 'a'
  buffer.setUint32(40, dataSize, Endian.little);

  // Audio samples
  int offset = 44;
  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final sampleVal = (generator(t, durationSec).clamp(-1.0, 1.0) * 32767).toInt();
    buffer.setInt16(offset, sampleVal, Endian.little);
    offset += 2;
  }

  return buffer.buffer.asUint8List();
}
