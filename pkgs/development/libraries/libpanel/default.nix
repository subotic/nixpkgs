{ stdenv
, lib
, fetchurl
, meson
, ninja
, pkg-config
, gobject-introspection
, vala
, gi-docgen
, glib
, gtk4
, libadwaita
, gnome
}:

stdenv.mkDerivation rec {
  pname = "libpanel";
  version = "1.5.0";

  outputs = [ "out" "dev" "devdoc" ];
  outputBin = "dev";

  src = fetchurl {
    url = "mirror://gnome/sources/libpanel/${lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
    sha256 = "sha256-E+8w55EpW7mYyHpzvJ0ZRXjC8sI9FKSJx4aX++7+kL4=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gobject-introspection
    vala
    gi-docgen
  ];

  buildInputs = [
    glib
    gtk4
    libadwaita
  ];

  mesonFlags = [
    "-Dinstall-examples=true"
  ];

  postFixup = ''
    # Cannot be in postInstall, otherwise _multioutDocs hook in preFixup will move right back.
    moveToOutput "share/doc" "$devdoc"
  '';

  passthru = {
    updateScript = gnome.updateScript {
      packageName = pname;
    };
  };

  meta = with lib; {
    description = "Dock/panel library for GTK 4";
    homepage = "https://gitlab.gnome.org/GNOME/libpanel";
    license = licenses.lgpl3Plus;
    maintainers = teams.gnome.members;
    platforms = platforms.unix;
  };
}
