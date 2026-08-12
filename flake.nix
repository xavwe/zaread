{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = inputs: {
    formatter."x86_64-linux" = inputs.nixpkgs.legacyPackages."x86_64-linux".nixfmt-tree;
    apps."x86_64-linux".lint = {
      type = "app";
      program = "${inputs.nixpkgs.legacyPackages."x86_64-linux".writeShellScript "lint" ''
        ${inputs.nixpkgs.lib.getExe inputs.nixpkgs.legacyPackages."x86_64-linux".shellcheck} zaread
      ''}";
    };
    packages."x86_64-linux".default = inputs.self.packages."x86_64-linux".zaread;
    packages."x86_64-linux".zaread =
      inputs.nixpkgs.legacyPackages."x86_64-linux".stdenvNoCC.mkDerivation
        rec {
          pname = "zaread";
          version = "2.0.0";

          src = ./.;

          dontBuild = true;

          nativeBuildInputs = with inputs.nixpkgs.legacyPackages."x86_64-linux"; [
            installShellFiles
            makeWrapper
          ];

          installPhase = ''
            installBin $src/zaread

            mkdir -p $out/share/applications/
            install -m444 ${

              inputs.nixpkgs.legacyPackages."x86_64-linux".makeDesktopItem {
                name = "zaread";
                desktopName = "zaread";

                exec = "zaread %f";
                tryExec = "zaread";

                comment = "Lightweight document reader";
                icon = "org.pwmt.zathura";

                noDisplay = true;
                terminal = false;

                categories = [
                  "Office"
                  "Viewer"
                ];

                mimeTypes = [
                  "application/pdf"
                  "image/vnd.djvu"
                  "application/epub+zip"
                  "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
                  "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                  "application/vnd.openxmlformats-officedocument.presentationml.presentation"
                  "application/msword"
                  "application/vnd.ms-excel"
                  "application/vnd.ms-powerpoint"
                  "application/vnd.oasis.opendocument.text"
                  "application/vnd.oasis.opendocument.spreadsheet"
                  "application/vnd.oasis.opendocument.presentation"
                  "application/vnd.ms-excel.sheet.macroEnabled.12"
                  "application/vnd.ms-excel.sheet.binary.macroEnabled.12"
                  "application/vnd.ms-word.document.macroEnabled.12"
                  "application/vnd.ms-powerpoint.presentation.macroEnabled.12"
                  "application/vnd.openxmlformats-officedocument.presentationml.slideshow"
                  "application/vnd.openxmlformats-officedocument.wordprocessingml.template"
                  "text/rtf"
                  "text/csv"
                  "application/x-mobipocket-ebook"
                  "text/markdown"
                ];
              }

            }/share/applications/* $out/share/applications/

            installManPage $src/zaread.1
          '';

          postFixup = ''
            wrapProgram "$out/bin/zaread" \
              --prefix PATH : "${
                inputs.nixpkgs.lib.makeBinPath [ inputs.nixpkgs.legacyPackages."x86_64-linux".file ]
              }" \
              --set ZA_READER_CMD "${
                inputs.nixpkgs.lib.getExe inputs.nixpkgs.legacyPackages."x86_64-linux".zathura
              }" \
              --set ZA_MOBI_CMD "${
                inputs.nixpkgs.lib.getExe' inputs.nixpkgs.legacyPackages."x86_64-linux".calibre "ebook-convert"
              }" \
              --set ZA_OFFICE_CMD "${
                inputs.nixpkgs.lib.getExe' inputs.nixpkgs.legacyPackages."x86_64-linux".libreoffice-fresh "soffice"
              }" \
              --set ZA_MD_CMD "${
                inputs.nixpkgs.lib.getExe inputs.nixpkgs.legacyPackages."x86_64-linux".md2pdf
              }" \
              --set ZA_TYPST_CMD "${
                inputs.nixpkgs.lib.getExe inputs.nixpkgs.legacyPackages."x86_64-linux".typst
              }"
          '';

          meta = {
            description = "A (very) lightweight MS Office file reader";
            homepage = "https://github.com/paoloap/zaread";
            license = inputs.nixpkgs.lib.licenses.gpl3Only;
            mainProgram = "zaread";
          };
        };
  };
}
