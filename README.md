# android-kit

The build and deploy scaffolding shared by Volv-G's Android apps (VME's
streamer, VWTF's weather widget, and whatever comes next), so each app
carries its code and nothing else. It is used as a git submodule at
`android/kit` and gives every app:

- **A private toolchain.** JDK 17 and the Android SDK, installed by
  `bootstrap.ps1` under one folder in `%LOCALAPPDATA%`. No admin rights,
  no Android Studio, nothing on PATH or in the registry, and one install
  for every app.
- **One Gradle and one set of versions.** The kit's Gradle wrapper builds
  every app. `versions.toml` is a version catalog that pins AGP, Kotlin,
  the SDK levels and the common AndroidX libraries; each app reads it as
  `kit`.
- **`build.cmd` and `deploy.cmd`.** These build, install over wireless
  debugging, launch and tail logcat. Phone addresses are found over mDNS,
  and each usual mistake comes with an explanation.
- **`new-app.ps1`** to start another app.

## An app on the kit

```
android/
  kit/                  this repo, as a submodule
  build.cmd             one-line hand-over to kit\build.cmd
  deploy.cmd            one-line hand-over to kit\deploy.cmd
  kit.properties        appId and the logcat tags deploy.cmd follows
  settings.gradle.kts   reads kit/versions.toml as the "kit" catalog
  build.gradle.kts      plugins at the kit's versions
  gradle.properties
  local.properties      gitignored: sdk.dir, and the app's own secrets
  app/                  the app
```

Clone with `--recursive`, or after a plain clone run
`git submodule update --init`. Then, once per app and machine:

```
powershell -NoProfile -ExecutionPolicy Bypass -File android\kit\bootstrap.ps1
android\build.cmd                    REM debug APK
android\build.cmd testDebugUnitTest  REM any Gradle task
android\deploy.cmd                   REM build, install, launch, tail logcat
android\deploy.cmd pair CODE         REM wireless debugging, once per phone
android\deploy.cmd connect           REM after each phone reboot
android\deploy.cmd apk               REM the APK's path, to sideload by hand
android\deploy.cmd find | log | devices
```

For a second app on the same machine, `bootstrap.ps1` skips everything up to
writing that app's `local.properties`. A phone paired for one app is paired
for all of them, because pairing belongs to the PC's adb key.

## A new app

From a checkout of this repo:

```
powershell -NoProfile -ExecutionPolicy Bypass -File new-app.ps1 -Repo ..\Tides -Name "Tides" -AppId works.tides
```

This writes `..\Tides\android` from `template\`: one activity that shows
the app's name and logs `started` under the log tag. If `..\Tides` is a
git repo, it also adds the kit as `android\kit`; otherwise it prints the
two commands that do. The result builds as it is.

## Changing the kit

- **Versions** are in `versions.toml`, and the reasons for each pin are
  there too. Raising `compileSdk` also changes what `bootstrap.ps1`
  installs, so run it again in each app.
- **Gradle** is set in `gradle/wrapper/gradle-wrapper.properties`.
  `bootstrap.ps1 -Force` regenerates the wrapper jar, which is not
  committed.
- **An app takes a new kit** on purpose:

  ```
  git submodule update --remote android/kit
  ```

  then build, and commit the moved submodule. Until then each app keeps
  the kit commit it was built and tested with.

## The toolchain folder

The toolchain lives in `ANDROID_KIT_TOOLCHAIN` if that is set, else in
`%LOCALAPPDATA%\android-kit`. A machine set up before the kit existed has
it in `%LOCALAPPDATA%\vme-android`; the kit uses that folder as long as
`android-kit` doesn't exist, and still honours the old
`VME_ANDROID_TOOLCHAIN` variable. Deleting the folder removes everything.
