# yt-dlp Android arm64 Standalone Build

Builds a single-file `yt-dlp` executable for Android arm64-v8a (no root
required), intended to be bundled inside a Flutter app's assets and run via
`Process.start()`.

Everything runs on GitHub Actions (`ubuntu-latest` runners). No local Linux,
Ubuntu, or WSL is required — you only need a browser and a GitHub account.

## How it works

Android has no native package manager for building a true cross-compiled
PyInstaller binary (PyInstaller must build *on* the target platform, and
GitHub Actions has no Android runner). Instead this repo:

1. Pulls a **prebuilt Python interpreter compiled for Android (bionic/arm64)**
   from the Termux package repository, via the official `termux-docker`
   image (which runs fine as a regular Docker container on the Ubuntu
   runner).
2. Builds `yt-dlp` into a `.pyz` zipapp.
3. Wraps the Python runtime + `.pyz` into a **self-extracting shell script**
   named `yt-dlp`, which is the single file you ship. On first run on the
   device it extracts itself into a private app directory and then execs
   Python against the zipapp; subsequent runs skip extraction.

## Usage

1. Push this repo to GitHub (or fork it).
2. Go to the **Actions** tab → select **Build yt-dlp for Android arm64** →
   **Run workflow** (or just push to `main`, it triggers automatically).
3. Once the run finishes, open the run page, scroll to **Artifacts**, and
   download `yt-dlp-android-arm64.zip`.
4. Unzip it — you'll have a single file named `yt-dlp`.

## Using it in Flutter

Asset files bundled with a Flutter app are not executable in place, so at
first launch copy it out to a writable, executable directory and mark it
executable:

```dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<File> installYtDlp() async {
  final appDir = await getApplicationSupportDirectory();
  final dest = File('${appDir.path}/yt-dlp');

  if (!await dest.exists()) {
    final bytes = await rootBundle.load('assets/yt-dlp');
    await dest.writeAsBytes(bytes.buffer.asUint8List());
    await Process.run('chmod', ['755', dest.path]);
  }
  return dest;
}

Future<void> runYtDlp(List<String> args) async {
  final exe = await installYtDlp();
  final result = await Process.start(exe.path, args,
      workingDirectory: exe.parent.path);
  // stream result.stdout / result.stderr as needed
}
```

## Notes and trade-offs

- The output file bundles a full Python runtime plus shared libraries, so
  expect tens of MB — this is not a lean native binary.
- First run on-device is slower because it self-extracts once into
  `.ytdlp_runtime/` next to the executable (override the target with the
  `YTDLP_HOME` environment variable if needed).
- Termux package versions on the remote repo change over time — pin exact
  versions in `scripts/fetch_termux_python.sh` if you need reproducible
  builds, or rely on the Docker step in the workflow, which always installs
  whatever is current in `termux-main`.
- If you'd rather avoid the self-extracting-shell-script approach entirely,
  consider **Chaquopy** or **python-for-android**, which embed Python
  directly into the Android/Gradle build instead of shelling out to a
  subprocess. Ask if you'd like that alternative fleshed out.

## Repository structure

```
yt-dlp-android-build/
├── .github/workflows/build.yml   # CI pipeline (GitHub Actions)
├── scripts/
│   ├── fetch_termux_python.sh    # manual/fallback Python-fetch method
│   ├── build_yt_dlp_pyz.sh       # builds yt-dlp.pyz zipapp
│   └── package_launcher.sh       # assembles the final self-extracting yt-dlp
├── launcher/
│   └── launcher_template.sh      # shell self-extractor template
└── README.md
```
