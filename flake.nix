{
    description = "CodeBoard";
    outputs = { self, nixpkgs }:
        let
            system = "x86_64-linux";
            pkgs = import nixpkgs {
                inherit system;
                config.allowUnfree = true;
            };
            vjdk = pkgs.jdk17;
            buildToolsVersion = "30.0.3";
            androidenv = pkgs.androidenv.override(old: { licenseAccepted = true; });
            androidComposition = androidenv.composeAndroidPackages {
                platformVersions = [ "34" ];
                includeEmulator = true;
                emulatorVersion = "33.1.17";
                buildToolsVersions = [ buildToolsVersion ];
                abiVersions = [ "x86" "x86_64" ];
                includeSystemImages = true;
            };
        in {
            devShells.${system}.default = pkgs.mkShell rec {
                ANDROID_SDK_ROOT =
                    "${androidComposition.androidsdk}/libexec/android-sdk";
                ANDROID_NDK_ROOT = "${ANDROID_SDK_ROOT}/ndk-bundle";

                buildInputs = with pkgs; with pkgs.xorg; [
                    androidComposition.androidsdk
                    androidComposition.platform-tools
                    vjdk
                    gradle
                    qemu
                    android-tools
                ];

                JAVA_HOME = vjdk.home;

                # GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${ANDROID_SDK_ROOT}/build-tools/${buildToolsVersion}/aapt2";
                GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${pkgs.aapt}/bin/aapt2";
            };
        };
}
