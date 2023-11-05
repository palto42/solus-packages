	# if ($FILE_EULA ne "" && $update == 0) {
	# 	if (!open(EULA, "<", $FILE_EULA)) {
	# 		abort($TRANSLATABLE_ERRORS[5], $FILE_EULA);
	# 	}
	# 	close EULA;
	# 	printf($TRANSLATABLE[5]);
	# 	my $answer = <STDIN>;

	# 	system("less '$FILE_EULA'");

	# 	if (yesNoAnswer($TRANSLATABLE[6], 0) == 0) {
	# 		abort($TRANSLATABLE_ERRORS[6], sprintf($TRANSLATABLE[7], $APPLICATION_NAME));
	# 	}
	# }#! /usr/bin/perl -w
################################################################################
#
# Linux Installations Script
#
################################################################################

use strict;

use Cwd;
use Cwd 'abs_path';
use File::Basename;
use File::Copy;
use File::Path qw(make_path);
use Getopt::Long;

################################################################################
#
# Einige Konfigurationskonstanten
#
################################################################################
my $IS_FOTOSCHAU_INSTALLER    = 0;
my $FILE_EULA				= "EULA.txt";
my $DOWNLOAD_SERVER			= "https://dls.photoprintit.com";
my $KEYACCID                  = '1773';
my $FULL_LOCALE               = 'de_DE';
my $CLIENTID                  = '38';
my $HPS_VER                   = '7.4.2';
my $VENDOR_NAME               = 'budni_fotowelt';
my $APPLICATION_NAME          = 'budni_fotowelt';
my $INSTALL_DIR_DEFAULT       = 'budni_fotowelt';
my $AFFILIATE_ID = "rp_specialofferpage_square-cal-okt_x_1773_x_01773-FjKVmE1jwmcTk ";
my $LEGACYVERSION_X32         = '7.3.3';

my $PROGRAM_NAME_HPS          = 'budni_fotowelt';
my $PROGRAM_NAME_FOTOSHOW     = 'cewe_fotoshau';
my $PROGRAM_NAME_FACEDETECTION		= "facedetection";
my $PROGRAM_NAME_GPUPROBE			= "gpuprobe";
my $PROGRAM_NAME_ICONEXTRACTOR		= "IconExtractor";
my $PROGRAM_NAME_REGEDIT			= "regedit";
my $PROGRAM_NAME_AUTOBOOKSERVICE	= "AutoBookService";
my $PROGRAM_NAME_QTWEBENGINEPROCESS	= "QtWebEngineProcess";
my $PROGRAM_NAME_INSTALLER			= "install.pl";
my $PROGRAM_NAME_UNINSTALLER		= "uninstall.pl";
my $PROGRAM_NAME_UPDATER			= "updater.pl";


################################################################################
#
# Texte
#
################################################################################
my @TRANSLATABLE;
my @TRANSLATABLE_ERRORS;

$TRANSLATABLE[0]  = "ja";
$TRANSLATABLE[1]  = "j";
$TRANSLATABLE[2]  = "nein";
$TRANSLATABLE[3]  = "n";
$TRANSLATABLE[4]  = "Dieses Script ist Ihnen bei der Installation von '\033[1m%1\$s %2\$s\033[0m' auf Ihrem Computer\nbehilflich und leitet Sie Schritt für Schritt durch den Installationsprozess.\n\n";
$TRANSLATABLE[5]  = "Bitte lesen Sie die EULA (End User License Agreement) sorgfältig durch. Im Anschluss\ndaran müssen Sie die EULA akzeptieren.\nInnerhalb der EULA können Sie mit den Pfeiltasten navigieren und durch drücken der\nTaste '\033[1mq\033[0m' verlassen Sie die EULA.\n\nWeiter mit <ENTER>.";
$TRANSLATABLE[6]  = "Akzeptieren Sie die EULA?";
$TRANSLATABLE[7]  = "\033[0m\033[1m'%1\$s'\033[0m kann leider nicht auf Ihrem Computer installiert werden.\n\n\n";
$TRANSLATABLE[8]  = "\nWo soll '\033[1m%1\$s %2\$s\033[0m' installiert werden? [\033[1m%3\$s\033[0m] ";
$TRANSLATABLE[9]  = "Wollen Sie die Installation fortsetzen und die benötigten Daten, insgesamt %1\$.2f MB,\naus dem Internet herunterladen?";
$TRANSLATABLE[10] = "Lade Paket '%1\$s' herunter ... ";
$TRANSLATABLE[11] = "\nDie benötigten Dateien werden nun in das Installationsverzeichnis entpackt.\n";
$TRANSLATABLE[12] = "\nHerzlichen Glückwunsch!\nSie haben erfolgreich \033[1m'%1\$s %2\$s'\033[0m auf Ihrem Computer installiert.\nZum Starten führen Sie bitte die Datei '%3\$s' aus.\n\nViel Spaß!\n";
$TRANSLATABLE[13] = "Soll erneut versucht werden die Datei herunter zu laden?";
$TRANSLATABLE[14] = "\t- %1\$-25s [%2\$.2f MB]\n";
$TRANSLATABLE[15] = "UNUSED";
$TRANSLATABLE[16] = "\nFür die Installation müssen noch folgenden Pakete aus dem Internet herunter geladen werden:\n";
$TRANSLATABLE[17] = "\nDie herunter geladenen Installationspakete wurden nach der Installation nicht gelöscht\nund befinden sich im aktuellen Verzeichnis.\n";
$TRANSLATABLE[18] = "UNUSED";
$TRANSLATABLE[19] = "Das angegebene Verzeichnis existiert nicht. Soll es angelegt werden?";
$TRANSLATABLE[20] = "Kommandozeilenoptionen:\n   -h; --help\n   -i; --installDir=<DIR>\tDas Verzeichnis in das '%1\$s' installiert werden soll.\n   -k; --keepPackages\t\tDie heruntergeladenen Pakete werden nicht gelöscht und können für eine weitere Installation benutzt werden.\n   -w; --workingDir=<DIR>\tDas Verzeichnis in dem temporäre Dateien abgelegt werden können.\n   -v; --verbose\t\tGibt Informationen beim Download aus.\n\nDas Script sucht im aktuellen Verzeichnis nach den Installationspaketen. Werden die Pakete dort nicht gefunden\nso werden sie aus dem Internet heruntergeladen\nTemporäre Dateien werden in das aktuelle oder das mit --workingDir angegebene Verzeichnis gespeichert. Ist das, wegen fehlender Berechtigungen, nicht möglich werden die temporären Dateien nach /tmp gespeichert.\n";
$TRANSLATABLE[21] = "Dieses Script ist Ihnen bei der Deinstallation von '\033[1m%1\$s\033[0m' behilflich.\nAchtung: Alle Daten im Verzeichnis '\033[1m%2\$s\033[0m' werden gelöscht. Möchten Sie fortfahren?";
$TRANSLATABLE[22] = "Entpacke Paket '%1\$s' ... ";
$TRANSLATABLE[23] = "fertig\n";
$TRANSLATABLE[24] = "\n'\033[1m%1\$s%2\$s\033[0m' wurde auf Ihrem Computer installiert. Damit '\033[1m%1\$s%2\$s\033[0m' korrekt ausgeführt werden kann, müssen noch die folgenden Bibliotheken (%3\$s) in Ihrem System installiert werden. Verwenden Sie dazu bitten den folgenden Befehl: '\033[1m%3\$s\033[0m' Bitte beachten Sie, dass dazu Root-Rechte benötigt werden.\nSoll das Script diesen Befehl jetzt ausführen?";
$TRANSLATABLE[25] = "'\033[1m$APPLICATION_NAME $HPS_VER\033[0m' wird auf Ihrem System nicht mehr unterstützt. Möchten Sie statt dessen \033[1m$APPLICATION_NAME %1\$s\033[0m installieren?";
$TRANSLATABLE[26] = "'\033[1m$APPLICATION_NAME %1\$s\033[0m' Setup wird heruntergeladen...\n";

$TRANSLATABLE_ERRORS[0]  = "Für die Kommandozeilenoptionen '--installDir' und '--workingDir' ist die Angabe eines Verzeichnisses zwingend erforderlich!\n";
$TRANSLATABLE_ERRORS[1]  = "Bei einem Update ist die Angabe des Installationsverzeichnisses mit '--installDir' zwingend erforderlich!\n";
$TRANSLATABLE_ERRORS[2]  = "Das angegebene Arbeitsverzeichnis '%1\$s' existiert nicht!\n";
$TRANSLATABLE_ERRORS[3]  = "Das Arbeitsverzeichnis konnte nicht ermittelt werden!\n";
$TRANSLATABLE_ERRORS[4]  = "Für die korrekte Ausführung des Scriptes wird das Programm '%1\$s' benötigt!\n";
$TRANSLATABLE_ERRORS[5]  = "Die Datei '%1\$s' kann nicht gefunden werden!\n";
$TRANSLATABLE_ERRORS[6]  = "\tSie haben die EULA nicht akzeptiert!\n\t%1\$s";
$TRANSLATABLE_ERRORS[7]  = "Im angegebenen Verzeichnis können keine symbolischen Links angelegt werden. Dies ist aber für die Installation von '%1\$s' zwingend erforderlich!\n";
$TRANSLATABLE_ERRORS[8]  = "Das Herunterladen der Datei '%1\$s' ist fehlgeschlagen!\n";
$TRANSLATABLE_ERRORS[9]  = "Die Datei '%1\$s' kann nicht geöffnet werden!\n";
$TRANSLATABLE_ERRORS[10] = "Die Plattform konnte nicht ermittelt werden! 'uname -m' liefert weder 'i686' noch 'x86_64' sondern '%1\$s'.\n";
$TRANSLATABLE_ERRORS[11] = "Die Datei '%1\$s' konnte nicht heruntergeladen werden!\n";
$TRANSLATABLE_ERRORS[12] = "Das Verzeichnis '%1\$s' konnte nicht angelegt werden.\n";
$TRANSLATABLE_ERRORS[13] = "Die Datei '%1\$s' kann nicht entpackt werden!\n";
$TRANSLATABLE_ERRORS[14] = "Die Datei '%1\$s' konnte nicht nach '%2\$s' kopiert werden!\n";
$TRANSLATABLE_ERRORS[15] = "Die Prüfsumme der heruntergeladenen Datei '%1\$s' stimmt nicht!\n";
$TRANSLATABLE_ERRORS[16] = "Die Datei '%1\$s' konnte nicht nach '%2\$s' herunter geladen werden!\n";
$TRANSLATABLE_ERRORS[17] = "Die benötigten Pakete konnten nicht ermittelt werden!\n";
$TRANSLATABLE_ERRORS[18] = "%1\$s wurde als '%2\$s' installiert. Bitte starten Sie die Deinstallation als Benutzer '%2\$s'.\n";
$TRANSLATABLE_ERRORS[19] = "Das Herunterladen von '\033[1m$APPLICATION_NAME %1\$s\033[0m' ist fehlgeschlagen!\n";
$TRANSLATABLE_ERRORS[20] = "\nDie Installation von '\033[1m$APPLICATION_NAME %1\$s\033[0m' ist fehlgeschlagen!\n";

my @ANSWER_YES_LIST	= ($TRANSLATABLE[0], $TRANSLATABLE[1]);
my @ANSWER_NO_LIST	= ($TRANSLATABLE[2], $TRANSLATABLE[3]);


################################################################################
#
# AB HIER SOLLTE NICHTS MEHR GEAENDERT WERDEN
# ===========================================
#
################################################################################


################################################################################
#
# Einige Konstanten
#
################################################################################
my $INDEX_FILE_PATH_ON_SERVER		= "/download/Data/$KEYACCID-$FULL_LOCALE/hps/$CLIENTID-index-$HPS_VER.txt";
my $MIME_TYPE						= "application/x-hps-$HPS_VER-mcf";
my $MIME_TYPE_FOTOSHOW				= "application/x-cewe-fotoschau-$HPS_VER";
my $APP_ICON_FILE_NAME				= "hps-$KEYACCID-$HPS_VER";
my $APP_ICON_FILE_NAME_FOTOSHOW		= "cewe-fotoschau-$KEYACCID-$HPS_VER";
my $PROGRAM_TO_START				= $PROGRAM_NAME_HPS;

if ($IS_FOTOSCHAU_INSTALLER == 1) {
	$INDEX_FILE_PATH_ON_SERVER	= "/cewe-myphotos/fs/$KEYACCID-$FULL_LOCALE/$CLIENTID-index-fotoplus-$HPS_VER.txt";
}

my $DESKTOP_ICON_PATH				= "/Resources/keyaccount/32.ico";
my $DESKTOP_ICON_PATH_FOTOSHOW		= "/Resources/keyaccount/fotoschau.ico";
my $SERVICES_XML_PATH				= "/Resources/services.xml";

my $INSTALL_DIR_DEF				= "$VENDOR_NAME/$INSTALL_DIR_DEFAULT";
my $LOG_FILE_DIR				= ".log";
my $INSTALL_LOG_FILE_NAME		= "install.log";
my @REQUIRED_PROGRAMMS			= ("unzip", "md5sum", "less", "wget", "uname");
my $DESKTOP_FILE_FORMAT			= "[Desktop Entry]\n".
									"Version=1.0\n".
									"Encoding=UTF-8\n".
									"Name=%s\n".
									"Exec=\"%s\" %s\n".
									"Path=%s\n".
									"StartupNotify=true\n".
									"Terminal=false\n".
									"Type=Application\n".
									"Icon=%s\n".
									"Categories=Graphics;\n".
									"MimeType=%s\n";
my $MIME_TYPE_FILE_FORMAT		= "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n".
									"<mime-info xmlns='http://www.freedesktop.org/standards/shared-mime-info'>\n".
									"<mime-type type=\"%s\">\n".
									"<comment>%s</comment>\n".
									"<glob pattern=\"*.mcf\"/>\n".
									"<glob pattern=\"*.mcfx\"/>\n".
									"<magic>\n".
									"<match value=\"createdWithHPSVersion\" type=\"string\" offset=\"0\"/>\n".
									"</magic>\n".
									"<icon name=\"%s\"/>\n".
									"</mime-type>\n".
									"</mime-info>\n";
my $SERVICES_XML_FORMAT			= "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>".
									"<services>".
									"<service name=\"a\">t856EvnDTL56xD5fHQnWrzqVk6Xj3we4xGYHfShPmkqXtCzbI21eqJ57eIHVViAg</service>".
									"<service name=\"b\">SNCxjcl5y86nasXrdmtwTWWbBmFs3j21rZOVvoZT9HleOfGJR7FGgZiXsS623ctV</service>".
									"<service name=\"c\">7iIwPfB9c6TIRuf9SPd7I1j25Pex9atTL9TDepMD6nkAyDliZhvIlJOC2tm9pcyQ</service>".
									"<service name=\"d\">%s</service>".
									"<service name=\"e\">EQBuKJf7pzVIbNXzz19PlwkVpERC5KfsWJbG4cazpn3PFC5Rtz4O3V87KcWfMgxK</service>".
									"<service name=\"f\">8ksOkroMJFn1Es3zVJyzxJggNaXiMuLKBfPLBtCyek1bZBcTy29gaU7nm75ZYIxz</service>".
									"<service name=\"g\">xHuXMWCLmtrwNIBvqVB9BAyPjNpEa9gNuybXU51bKsryDqc2UJxSQXM8yIhbIarq</service>".
									"<service name=\"h\">sKTtqevc5EdBSwi3bZkngwl4NSolB8vFc7kPWeAEB4Y1ySgUIgcjJGxKlOll8c8e</service>".
									"</services>\n";

my $DOWNLOAD_START_URL			= "http://dls.photoprintit.com/api/feedback/$KEYACCID/hps/<update>downloadstart.$AFFILIATE_ID/linux/$HPS_VER";
my $DOWNLOAD_COMPLETE_URL		= "http://dls.photoprintit.com/api/feedback/$KEYACCID/hps/<update>downloadcomplete.$AFFILIATE_ID/linux/$HPS_VER";
my $INSTALLATION_COMPLETE_URL	= "http://dls.photoprintit.com/api/feedback/$KEYACCID/hps/<update>installationcomplete.$AFFILIATE_ID/linux/$HPS_VER";

my %LIBRARIES_TO_INSTALL = (
	ubuntu => ["dpkg", "-s", "apt", "install", ["libxcb-xinerama0", "libsnappy1v5", "libgstreamer-gl1.0-0", "gstreamer1.0-libav"]],
	linuxmint => ["dpkg", "-s", "apt", "install", ["libxcb-xinerama0", "libgstreamer-gl1.0-0", "gstreamer1.0-libav"]],
	opensuseleap => ["rpm", "-q", "zypper", "install", ["libxcb-xinerama0", "libsnappy1", "gstreamer-plugins-libav"]],
	opensusetumbleweed => ["rpm", "-q", "zypper", "install", ["libsnappy1", "gstreamer-plugins-libav"]],
	debian => ["dpkg", "-s", "apt", "install", ["libxcb-xinerama0", "libxcb-icccm4", "libxcb-keysyms1", "libxcb-randr0", "libxcb-render-util0", "libxcb-xkb1", "libxkbcommon-x11-0", "libxcb-image0", "libgstreamer-gl1.0-0", "gstreamer1.0-libav"]]
);

my $LEGACY_VERSION_SERVER_PATH	= "/api/getClient/$KEYACCID-$FULL_LOCALE/hps/%s/linux/%s";

################################################################################
#
# Variablen
#
################################################################################
my $indexContent;			# Enthält den Inhalt der Index-Datei
my @filesToDownload;		# Enthält die Dateinamen die heruntergeladen werden müssen
my %packagesToUnzip;		# Enthält die Dateinamen der heruntergeladenen Dateien
my @packagesToRemove;		# Enthält die Dateinamen der Pakete, die am Ende des Scripts wieder gelöscht werden müssen.
my @filesToRemove;			# Enthält die Dateinamen der Dateien die am Ende des Scriptes gelöscht werden müssen.
my @filesCreated;			# Enthält die Dateien, die vom Installer zusätzlich angelegt wurden.
my @uninstallCommands;		# Enthält die Befehle, die der Uninstaller ausführen muss um den HPS wieder komplett zu deinstallieren.
my $fileName;				# Enthält den Namen der aktuell zu bearbeitenden Datei
my $update;
my $upgrade;
my $installDir = "";
my $sourceDir = "";
my $changeInstallDir = 1;
my $verbose;
my $keepPackages = 0;
my $workingDir = cwd();		# Aktuelles Verzeichnis wird das Arbeitsverzeichnis.
my $deepLink = "";			# Enthält den aus der Affiliate Id extrahierte DeepLink
my $autoBookServiceState = 0;



################################################################################
#
# Zeige einen kleinen Hilfetext an
#
################################################################################
sub showHelp {
	printf ($TRANSLATABLE[4], $APPLICATION_NAME, $HPS_VER);
	printf ($TRANSLATABLE[20], $APPLICATION_NAME);

	exit(0);
}


################################################################################
#
# Parse Kommandozeilen Parameter
#
################################################################################
sub getOptions {
	$update = 0;
	$upgrade = 0;
	$verbose = 0;
	$installDir = "";
	my $showHelp = 0;

	GetOptions("installdir=s" => \$installDir,
				"update" => \$update,
				"upgrade" => \$upgrade,
				"verbose" => \$verbose,
				"help" => \$showHelp,
				"keepPackages" => \$keepPackages,
				"workingdir=s" => \$workingDir) || abort($TRANSLATABLE_ERRORS[0]);

	if ($showHelp == 1) {
		showHelp();
	}

	if ($upgrade == 1) {
		$update = 1;
	}

	if ($update == 1
	   && $installDir eq "") {
		abort($TRANSLATABLE_ERRORS[1]);
	}

	if ($installDir ne "") {
		$changeInstallDir = 0;
	}
}

################################################################################
#
# Status des AutoBookService ermitteln.
#
################################################################################
sub getAutoBookServiceState {
	my $autoBookServiceExecutable = "$installDir/$PROGRAM_NAME_AUTOBOOKSERVICE";

	if (-x $autoBookServiceExecutable) {
		system("\"$autoBookServiceExecutable\" --serviceMode s > /dev/null 2>&1");
		$autoBookServiceState = $? >> 8;
	} else {
#		print ("$autoBookServiceExecutable not found");
		$autoBookServiceState = 0;
	}

	if ($verbose != 0) {
		print ("AutoBookServiceState = $autoBookServiceState\n");
	}
}

################################################################################
#
# AutoBookService beenden und Autostart-Datei entfernen
#
################################################################################
sub stopAutoBookService {
	getAutoBookServiceState();

	system("\"$installDir/$PROGRAM_NAME_AUTOBOOKSERVICE\" --serviceMode u > /dev/null 2>&1");
}

################################################################################
#
# AutoBookService starten, Autostart-Datei erzeugen lassen und im Hintergrund
# weiter laufen lassen
#
################################################################################
sub startAutoBookService {
	if ($autoBookServiceState != 0) {
		system("\"$installDir/$PROGRAM_NAME_AUTOBOOKSERVICE\" --serviceMode i > /dev/null 2>&1 &");
	}
}

################################################################################
#
# Deinstalliert den ganzen HPS wieder.
#
################################################################################
sub uninstall {
	$installDir = dirname(abs_path(__FILE__));
	my $ownerUID = (stat($installDir))[4];

	if ($ownerUID ne $>) {
		abort(sprintf($TRANSLATABLE_ERRORS[18], $APPLICATION_NAME, getpwuid($ownerUID)));
	}

	if (yesNoAnswer(sprintf($TRANSLATABLE[21], $APPLICATION_NAME, $installDir), 0)) {
		if (opendir(LOG_FILE_DIR, "$installDir/$LOG_FILE_DIR")) {

			# AutoBookService beenden
			stopAutoBookService();

			my @allFiles = readdir(LOG_FILE_DIR);
			@allFiles=grep(!/^\./, @allFiles);

			close(LOG_FILE_DIR);

			foreach (@allFiles) {
				removePackage("$installDir/$LOG_FILE_DIR/$_");
			}
		}

		# Alle leeren Verzeichnisse wegräumen.
		system("find \"$installDir\" -type d -empty -delete");
	}

	exit 0;
}


################################################################################
#
# Liest eine Ja/Nein Entscheidung des Benutzers ein
#
################################################################################
sub yesNoAnswer {
	my $text = $_[0];
	my $default = $_[1];
	my $choice;

	# if ($default == 1) {
	# 	$choice = sprintf("[\033[1m%1\$s\033[0m/%2\$s]", uc($TRANSLATABLE[0]), $TRANSLATABLE[2]);
	# } else {
	# 	$choice = sprintf("[%1\$s/\033[1m%2\$s\033[0m]", $TRANSLATABLE[0], uc($TRANSLATABLE[2]));
	# }

	# printf("$text $choice ");

	# my $answer = <STDIN>;
	# chomp($answer);
	# $answer = lc($answer);

	# if ($answer ~~ @ANSWER_YES_LIST) {
	# 	return 1;
	# } elsif ($answer ~~ @ANSWER_NO_LIST) {
	# 	return 0;
	# }

	return $default;
}


################################################################################
#
# Prüft das Arbeitsverzeichnis
#
################################################################################
sub checkWorkingDir {
	my $testFileName = "test";

	if (!opendir(DIR, $workingDir)) {
		abort($TRANSLATABLE_ERRORS[2], $workingDir);
	} else {
		closedir(DIR);
	}
	my $testFilePath = "$workingDir/$testFileName";

	if (!open(TEST_FILE, ">", $testFilePath)) {
		$workingDir = "/tmp";
		$testFilePath = "$workingDir/$testFileName";

		if (!open(TEST_FILE, ">", $testFilePath)) {
			abort($TRANSLATABLE_ERRORS[3]);

		} else {
			close(TEST_FILE);
			unlink($testFilePath);
		}
	} else {
		close(TEST_FILE);
		unlink($testFilePath);
	}
}


################################################################################
#
# Prüfe ob benötigte Programme da sind
#
################################################################################
sub checkProgramms {
	foreach (@REQUIRED_PROGRAMMS) {
		my $status = system("which $_ > /dev/null 2>&1");

		if ($status != 0) {
			abort($TRANSLATABLE_ERRORS[4], $_);
		}
	}
}


################################################################################
#
# Zeigt die EULA an
#
################################################################################
sub showEula {
	# if ($FILE_EULA ne "" && $update == 0) {
	# 	if (!open(EULA, "<", $FILE_EULA)) {
	# 		abort($TRANSLATABLE_ERRORS[5], $FILE_EULA);
	# 	}
	# 	close EULA;
	# 	printf($TRANSLATABLE[5]);
	# 	my $answer = <STDIN>;

	# 	system("less '$FILE_EULA'");

	# 	if (yesNoAnswer($TRANSLATABLE[6], 0) == 0) {
	# 		abort($TRANSLATABLE_ERRORS[6], sprintf($TRANSLATABLE[7], $APPLICATION_NAME));
	# 	}
	# }
}


################################################################################
#
# Installationsverzeichniss erfragen
#
################################################################################
sub getInstallDir {
	if ($update == 0 && $changeInstallDir == 1) {
		while (1) {
			if ($> == 0) {	# Root User
				$installDir = "/usr/bin/$INSTALL_DIR_DEF";
			} else {		# Normaler Benutzer
				$installDir = "$ENV{'HOME'}/$INSTALL_DIR_DEF";
			}

			printf($TRANSLATABLE[8], $APPLICATION_NAME, $HPS_VER, $installDir);
			my $answer = <STDIN>;
			chomp($answer);

			if ($answer ne "") {
				$installDir = $answer;
			}

			# vorne und hinten Leerzeichen abschneiden
			$installDir =~ s/^\s+//;
			$installDir =~ s/\s+$//;

			# Jetzt ersetzen wir noch die Tilde durch das Home-Verzeichnis
			$installDir =~ s/^~/$ENV{"HOME"}/;

			# einen relativen Pfad um den aktuellen Pfad erweitern
			if ($installDir =~ m/^[^\/]/) {
				$installDir = "$ENV{'PWD'}/$installDir";
			}

			my $dirCreated = 0;
			if (! -e $installDir) {
				if (yesNoAnswer($TRANSLATABLE[19], 1)) {
					# Installationsverzeichniss anlegen
					make_path("$installDir/$LOG_FILE_DIR", {error => \my $error });

					if (@$error) {
						printf(red($TRANSLATABLE_ERRORS[12]), $installDir);
						next;
					}

					$dirCreated = 1;
				} else {
					next;
				}
			}

			my $symlinkTestFile = "$installDir/symlinks_possible";
			my $symlinks_possible = symlink($symlinkTestFile, $symlinkTestFile);

			if ($symlinks_possible) {
				unlink $symlinkTestFile;
				last;
			} else {
				if ($dirCreated == 1) {
					rmtree($installDir);
				}
				abort($TRANSLATABLE_ERRORS[7], $APPLICATION_NAME);
			}
		}
	}
}


################################################################################
#
# Holt die Index-Datei
#
################################################################################
sub getIndexFile {
	my $downloaded = 0;
	my $answer = 1;

	$fileName = basename($INDEX_FILE_PATH_ON_SERVER);

	if (! -e $fileName
		|| -s $fileName == 0) {
		# Hole Indexdatei aus dem Netz.

		$fileName = "$workingDir/$fileName";

		if ($verbose == 0) {
			$answer = system("wget -T 60 -t 1 -q '$DOWNLOAD_SERVER$INDEX_FILE_PATH_ON_SERVER' -O '$fileName'");
		} else {
			$answer = system("wget -T 60 -t 1 '$DOWNLOAD_SERVER$INDEX_FILE_PATH_ON_SERVER' -O '$fileName'");
		}

		if ($answer != 0
			|| -s $fileName == 0) {
			unlink($fileName);
			abort($TRANSLATABLE_ERRORS[8], $DOWNLOAD_SERVER.$INDEX_FILE_PATH_ON_SERVER);
		}

		$downloaded = 1;
	}

	if (!open(INDEX, "<", $fileName)) {
		abort($TRANSLATABLE_ERRORS[9], $fileName);

	} else {
		while(<INDEX>) {
			$indexContent.=$_;
		}

		close(INDEX);

		if ($downloaded == 1 && $keepPackages == 0) {
			push(@packagesToRemove, $fileName);
		}
	}
}


################################################################################
#
# Checkt Index-Datei und sucht die herunter zu ladenden Dateien zusammen
#
################################################################################
sub checkIndexFile {
	my $totalSize = 0;
	my $packageString = "";
	my $machineType = `uname -m`;

	chomp($machineType);

	if ($machineType eq "i686") {
		$machineType = "l";
	} elsif ($machineType eq "x86_64") {
		$machineType = "l64";
	} else {
		abort($TRANSLATABLE_ERRORS[10], $machineType);
	}

	if (length($indexContent) == 0) {
		abort($TRANSLATABLE_ERRORS[17]);
	}

	foreach (split(/[\r\n]+/, $indexContent)) {
		chomp;
		if (/^(.*);(.*);(.*);(.*)$/) {
			my $filePath = $1;
			my $required = $2;
			my $what = $3;
			my $system = $4;

			if ($system eq $machineType || $system eq "a") {
				$fileName = basename($filePath);

				if (! -e "$installDir/$LOG_FILE_DIR/$fileName.log") {
					# Die Datei ist noch nicht installiert.
					if ( -e $fileName ) {
						# Die Datei liegt lokal vor, also brauchen wir sie nicht herunter zu laden
						$packagesToUnzip{$fileName} = $what;
#						push(@packagesToUnzip, $fileName);

					} else {
						my $file2get;
						if ($filePath =~ m/^https:/) {
							$file2get = $filePath;
						} else {
							$file2get = "$DOWNLOAD_SERVER/$filePath";
						}
						# Die Datei muss aus dem Netz gezogen werden. Schreiben wir mal raus wie viel da herunter geladen werden muss.
						my $spider = `export LANG=C;export LC_MESSAGES=C;wget --spider '$file2get' 2>&1`;
						my ($size, $dummy, $mb, $mime)	= $spider=~/Length:\s+([\d\.,]+)\s+(\(([\d\.,]+[MK]?)\))?\s*(\[.*\])/;
						my $string = sprintf($TRANSLATABLE[14], $what, $size/(1024*1024));
						$packageString .= $string;
						push(@filesToDownload, $_);
						$size =~ s/[\.,]//g;
						$totalSize += $size;
					}
				}
			}
		}
	}

	if (scalar(@filesToDownload) != 0) {
		printf($TRANSLATABLE[16]);
		printf($packageString);
		if ($update == 0
			&& yesNoAnswer(sprintf($TRANSLATABLE[9], $totalSize/(1024*1024)), 1) == 0) {
			exit 1;
		}
	}
}


################################################################################
#
# Löscht ein altes Paket wieder von der Platte, welches nicht mehr benutzt wird.
#
################################################################################
sub roleback {
	my ($fileName) = @_;
	$fileName =~ /^$CLIENTID-(.*)-(\d+.\d+.\d+)_.*$/;
	my $packageName = $1;

	if (opendir(LOG_FILE_DIR, $installDir."/".$LOG_FILE_DIR)) {
		my @allFiles=readdir(LOG_FILE_DIR);
		@allFiles=grep(!/^\./, @allFiles);

		close(LOG_FILE_DIR);

		foreach (@allFiles) {
			$_ =~ /^$CLIENTID-(.*)-(\d+.\d+.\d+)_.*$/;

			if ($1 eq $packageName) {
				removePackage("$installDir/$LOG_FILE_DIR/$_");
			}
		}
	}
}


################################################################################
#
# Lösche Dateien aus einem Logfile und das Logfile selbst
#
################################################################################
sub removePackage {
	my $logFile = $_[0];
	my @files;
	my @dirs;

	if (open(LOG_FILE, "<", $logFile)) {
		while(<LOG_FILE>) {
			if (/^\s*inflating:\s+(.*)/) {
				my $file = $1;
				$file =~ s/^\s+|\s+$//;
				push(@files, $file);
			}
			if (/^\s*creating:\s+(.*)\s*$/) {
				push(@dirs, $1);
			}
			if (/^\s*created:\s+(.*)/) {
				my $file = $1;
				$file =~ s/^\s+|\s+$//;
				push(@files, $file);
			}
			if (/^\s*command:\s+(.*)/) {
				system($1);
			}
		}
		close LOG_FILE;
	}

	# Füge das Logfile zur Liste der zu löschenden Dateien hinzu.
	push(@files, $logFile);

	unlink(@files);

	foreach (reverse(@dirs)) {
		rmdir($_);
	}
}


################################################################################
#
# Lädt alle Dateien aus der Index-Datei herunter
#
################################################################################
sub downloadFiles {
	if (scalar(@filesToDownload) != 0) {

		# triggerCountPixel($DOWNLOAD_START_URL);

		# Herunterladen der Dateien
		foreach (@filesToDownload) {
			chomp;
			$_ =~ /^(.*);.*;(.*);.*$/;
			my $filePath = $1;
			my $what = $2;
			my $error = 0;
			my $retry = 1;

			$fileName = $workingDir . "/" . basename($filePath);

			printf($TRANSLATABLE[10], $what);

			while($retry == 1) {
				my $result = 1;
				my $file2get;

				if ( $filePath =~ m/^https:/) {
				   $file2get = $filePath;
				} else {
				   $file2get = $DOWNLOAD_SERVER."/".$filePath;
				}

				if ($verbose == 0) {
					$result = system("wget -q '$file2get' -O '$fileName'");
				} else {
					$result = system("wget '$file2get' -O '$fileName'");
				}

				if ($result == 0) {
					# Extrahiere MD5 Summe
					$fileName =~ /^.*_(.*).zip$/;
					my $md5sum = $1;

					# Berechne MD5 Summe der Datei
					$result = `md5sum '$fileName'`;
					$result =~ /^(\w*)\s+.*$/;
					my $fileMd5sum = $1;

					if ($md5sum ne $fileMd5sum) {
						printf(red($TRANSLATABLE_ERRORS[15]), $fileName);
						$error = 1;
					} else {
						$packagesToUnzip{$fileName} = $what;
#						push(@packagesToUnzip, $fileName);
						push(@packagesToRemove, $fileName);
						$retry = 0;
					}
				} else {
					printf(red($TRANSLATABLE_ERRORS[16]), $file2get, $fileName);
					$error = 1;
				}

				if ($update == 0 && $error == 1) {
					$retry = yesNoAnswer($TRANSLATABLE[13], 0);

				} elsif ($update == 1 && $error == 1) {
					# Wir haben keine Konsole und können keine Eingabe entgegen nehmen.
					# Deshalb brechen wir ab.
					$retry = 0;
				}
			}

			printf($TRANSLATABLE[23]);

			if ($error == 1) {
				unlink $fileName;
				abort($TRANSLATABLE_ERRORS[11], $fileName);
			}
		}

		# triggerCountPixel($DOWNLOAD_COMPLETE_URL);
	}
}


################################################################################
#
# Prüfen und entpacken der Dateien
#
################################################################################
sub unpackFiles {
	if (scalar(keys(%packagesToUnzip)) != 0) {
		printf($TRANSLATABLE[11]);

		make_path("$installDir/$LOG_FILE_DIR", {error => \my $error });

		if (@$error) {
			abort(red($TRANSLATABLE_ERRORS[12]), $installDir);
		}

		# Alte symbolische Links wegwerfen, System Integration, Icons, Mimetype, ... löschen
		removePackage("$installDir/$LOG_FILE_DIR/$INSTALL_LOG_FILE_NAME");

		# Entpacken der Dateien
		foreach (keys(%packagesToUnzip)) {
			chomp;
			$fileName = $_;
			my $fileBaseName = basename($fileName);

			printf($TRANSLATABLE[22], $packagesToUnzip{$fileName});

			# Hier können wir eine evtl. installierte Vorgängerversion löschen.
			# Die md5 Summen aller Downloads stimmen, also sollten sich alle Pakete entpaken lassen
			roleback($fileBaseName);

			my $result = 0;
			my @unzipReturn;
			@unzipReturn = `unzip -o -d '$installDir' '$fileName' 2>&1`;

			foreach (@unzipReturn) {
				if (/^\s*error:/) {
					$result = 1;
				} elsif (/cannot find/) {
					$result = 1;
				}
			}

			if (open(OUT, ">", "$installDir/$LOG_FILE_DIR/$fileBaseName.log")) {
				print OUT  @unzipReturn;
				close(OUT);
			}

			if ($result != 0) {
				abort($TRANSLATABLE_ERRORS[13], $fileName);
			}

			printf($TRANSLATABLE[23]);
		}
	}
}


################################################################################
#
# Ein Icon für Mimetyp und Application erzeugen
#
################################################################################
sub createIcon {
	my ($iconPath, $appIconName, $mimeType) = @_;

	$mimeType =~ tr:/:-:;

	my @sizes = (16, 22, 24, 32, 48, 64, 128);

	system("\"$installDir/$PROGRAM_NAME_ICONEXTRACTOR\" \"$installDir$iconPath\" @sizes $appIconName > /dev/null 2>&1");

	# foreach (@sizes) {
	# 	my $size = $_;
	# 	my $iconFileName = $appIconName."_".$size.".png";

	# 	system("xdg-icon-resource install --noupdate --theme hicolor --context apps --size $size $iconFileName $appIconName");
	# 	push(@uninstallCommands, "xdg-icon-resource uninstall --noupdate --theme hicolor --context apps --size $size $appIconName");

	# 	if ($mimeType ne "") {
	# 		system("xdg-icon-resource install --noupdate --theme hicolor --context mimetypes --size $size $iconFileName $mimeType");
	# 		push(@uninstallCommands, "xdg-icon-resource uninstall --noupdate --theme hicolor --context mimetypes --size $size $mimeType");
	# 	}

	# 	push(@filesToRemove, $iconFileName);
	# }

	# system("xdg-icon-resource forceupdate");
	# push(@uninstallCommands, "xdg-icon-resource forceupdate");
}


################################################################################
#
# Icons für Mimetyp und Application erzeugen
#
################################################################################
sub createIcons {
	if ($IS_FOTOSCHAU_INSTALLER != 1) {
		createIcon($DESKTOP_ICON_PATH,			$APP_ICON_FILE_NAME,				$MIME_TYPE);
	}

	createIcon($DESKTOP_ICON_PATH_FOTOSHOW,		$APP_ICON_FILE_NAME_FOTOSHOW,		$MIME_TYPE_FOTOSHOW);
}


################################################################################
#
# Informationen zum Mimetyp erzeugen.
#
################################################################################
sub createMimeType() {
	if ($IS_FOTOSCHAU_INSTALLER != 1) {
		my $mimeTypeFileName = "$MIME_TYPE.xml";
		$mimeTypeFileName =~ tr:/:-:;

		if (!open(MIME_TYPE_FILE, ">", "$mimeTypeFileName")) {
			abort($TRANSLATABLE_ERRORS[9], $mimeTypeFileName);

		} else {
			printf(MIME_TYPE_FILE $MIME_TYPE_FILE_FORMAT, $MIME_TYPE, $APPLICATION_NAME, ($MIME_TYPE=~s/\//-/r));
			close(MIME_TYPE_FILE);

			system("xdg-mime install \"$mimeTypeFileName\"");
			push(@uninstallCommands, "xdg-mime uninstall \"$mimeTypeFileName\"");

			my $mimeDir = "$ENV{'HOME'}/.local/share/mime";
			if ($> == 0) {
				$mimeDir = "/usr/share/mime";
			}

			system("update-mime-database \"$mimeDir\"");
			push(@uninstallCommands, "update-mime-database $mimeDir");
		}

		push(@filesCreated, "$installDir/$mimeTypeFileName");
	}
}


################################################################################
#
# Einen Eintrag im Startmenü erzeugen.
#
################################################################################
sub createDesktopShortcut {
	my ($executableName, $iconName, $mimeType, $installURLSchemaHandler) = @_;

	my $desktopFileName = "$iconName.desktop";
	$desktopFileName =~ tr:/:-:;

	if (!open(DESKTOP_FILE, ">", $desktopFileName)) {
		abort($TRANSLATABLE_ERRORS[9], $desktopFileName);

	} else {
		printf(DESKTOP_FILE $DESKTOP_FILE_FORMAT, $executableName, $installDir."/".$executableName, "%u", $installDir, $iconName, $mimeType);
		close(DESKTOP_FILE);

		system("xdg-desktop-menu install --novendor \"$desktopFileName\"");
		push(@uninstallCommands, "xdg-desktop-menu uninstall \"$desktopFileName\"");

		system("xdg-desktop-icon install --novendor \"$desktopFileName\"");
		push(@uninstallCommands, "xdg-desktop-icon uninstall \"$desktopFileName\"");

		if ($installURLSchemaHandler == 1) {
			system("xdg-mime default \"$desktopFileName\" x-scheme-handler/hps-$KEYACCID");
		}
	}

	push(@filesCreated, "$installDir/$desktopFileName");
}


################################################################################
#
# Einträge im Startmenü erzeugen
#
################################################################################
sub createDesktopShortcuts {
	if ($IS_FOTOSCHAU_INSTALLER != 1) {
		createDesktopShortcut($PROGRAM_NAME_HPS,		$APP_ICON_FILE_NAME,				$MIME_TYPE,				1);
	}

	createDesktopShortcut($PROGRAM_NAME_FOTOSHOW,		$APP_ICON_FILE_NAME_FOTOSHOW,		$MIME_TYPE_FOTOSHOW,	0);

	system("xdg-desktop-menu forceupdate");
	push(@uninstallCommands, "xdg-desktop-menu forceupdate");
}


################################################################################
#
# Pfade zu den gerade installierten Executables in die Registry eintragen.
#
################################################################################
sub registerExecutables {
	if ($IS_FOTOSCHAU_INSTALLER == 1) {
		system("\"$installDir/$PROGRAM_NAME_REGEDIT\" --fs \"$installDir/$PROGRAM_NAME_FOTOSHOW\" --dl \"$deepLink\" > /dev/null 2>&1");
	} else {
		system("\"$installDir/$PROGRAM_NAME_REGEDIT\" --fs \"$installDir/$PROGRAM_NAME_FOTOSHOW\" --dl \"$deepLink\" --hps \"$installDir/$PROGRAM_NAME_HPS\" > /dev/null 2>&1");
	}
}


################################################################################
#
# Abschließende Arbeiten, symbolische Links anlegen, Programme ausführbar machen, ...
#
################################################################################
sub finalizeInstallation {
	if (opendir(INSTALL_DIR, $installDir)) {
		chdir($installDir);
		my @allFiles=sort{ $a cmp $b } readdir(INSTALL_DIR);

		# Werfe alle Einträge mit einem Punkt am Anfang weg
		@allFiles=grep(!/^\./, @allFiles);
		my @libFiles=grep(/.+\.so\.\w*/, @allFiles);

		# Erzeuge Symlinks für Libs
		foreach (@libFiles) {
			my $fileName = $_;

			if (-l $fileName) {
				# symbolische Links auf symbolische Links wollen wir nicht.
				next;
			}

			$fileName =~ /(.+\.so)\.(.*)/;
			my $baseFileName = $1;
			my $version = $2;

			my @v = split(/\./, $version);

			unlink($baseFileName);
			symlink($fileName, $baseFileName);
			push(@filesCreated, "$installDir/$baseFileName");

			foreach (@v) {
				$baseFileName .= ".$_";
				if ($baseFileName ne $fileName) {
					unlink($baseFileName);
					symlink($fileName, $baseFileName);
					push(@filesCreated, "$installDir/$baseFileName");
				}
			}
		}

		# Kopiere Uninstall Script und EULA ins Installationsverzeichnis.
		my %filesToCopy;
		$filesToCopy{$PROGRAM_NAME_INSTALLER} = $PROGRAM_NAME_UNINSTALLER;
		$filesToCopy{$FILE_EULA} = $FILE_EULA;
		my @sourceFiles = keys(%filesToCopy);

		foreach (@sourceFiles) {
			my $sourceFile = "$workingDir/$_";
			my $targetFile = "$installDir/$filesToCopy{$_}";

			copy("$sourceFile", $targetFile);
			push(@filesCreated, $targetFile);
		}

		# Ändere Dateirechte
		my @binaries;
		push(@binaries, $PROGRAM_NAME_HPS);
		push(@binaries, $PROGRAM_NAME_FOTOSHOW);
		push(@binaries, $PROGRAM_NAME_UNINSTALLER);
		push(@binaries, $PROGRAM_NAME_FACEDETECTION);
		push(@binaries, $PROGRAM_NAME_GPUPROBE);
		push(@binaries, $PROGRAM_NAME_ICONEXTRACTOR);
		push(@binaries, $PROGRAM_NAME_REGEDIT);
		push(@binaries, $PROGRAM_NAME_QTWEBENGINEPROCESS);
		push(@binaries, $PROGRAM_NAME_UPDATER);
		push(@binaries, $PROGRAM_NAME_AUTOBOOKSERVICE);

		chmod(0755, @binaries);

		closedir(INSTALL_DIR);
	}

	if ($AFFILIATE_ID ne '') {
		($AFFILIATE_ID, $deepLink) = split('\*+', $AFFILIATE_ID, 2);

		$deepLink =~ s/ +$//;

		$AFFILIATE_ID .= " " x 256;
		$AFFILIATE_ID = substr $AFFILIATE_ID, 0, 256;

		my $servicesXMLFilePath = "$installDir/$SERVICES_XML_PATH";

		if (open(SERVICESXML, ">", $servicesXMLFilePath)) {
			printf SERVICESXML $SERVICES_XML_FORMAT, $AFFILIATE_ID;
			close(SERVICESXML);

			push(@filesCreated, $servicesXMLFilePath);
		}
	}
}


################################################################################
#
# Zählpixel URL aufrufen und die dabei heruntergeladene Datei löschen.
#
################################################################################
sub triggerCountPixel {
	my $pixelFile = "pixel";

	if ($upgrade == 1) {
		$_[0] =~ s/<update>/genericupgrade/;
	} elsif ($update == 1) {
		$_[0] =~ s/<update>/update/;
	} else {
		$_[0] =~ s/<update>//;
	}

	if ($workingDir ne "") {
		$pixelFile = "$workingDir/$pixelFile";
	}

	system("wget -q $_[0] -O '$pixelFile'");
	unlink $pixelFile
}


################################################################################
#
# Meldung in rot.
#
################################################################################
sub red {
	return sprintf("\033[31m%s\033[0m", $_[0]);
}


################################################################################
#
# Fehlermeldung ausgeben und abbrechen
#
################################################################################
sub abort {
	my $message = shift(@_);
	printf(red($message), @_);
	exit 1;
}


################################################################################
#
# Übersetzungen laden
#
################################################################################
sub loadTranslations {
	if (open(TRANSLATIONS, "<", "translations.pl")) {
		my $translationCode;

		while(<TRANSLATIONS>) {
			$translationCode .= $_;
		}

		close(TRANSLATIONS);

		eval($translationCode);

		@ANSWER_YES_LIST = ($TRANSLATABLE[0], $TRANSLATABLE[1]);
		@ANSWER_NO_LIST  = ($TRANSLATABLE[2], $TRANSLATABLE[3]);
	}
}


################################################################################
#
# Aufräumen, alle angelegten Dateien entfernen.
#
################################################################################
sub cleanup {
	if ($keepPackages == 0) {
		unlink(@packagesToRemove);
	} else {
		printf($TRANSLATABLE[17]);
	}

	unlink(@filesToRemove);
}


################################################################################
#
# Datei schreiben, was ausgeführt und gelöscht werden muss um den HPS wieder komplett zu deinstallieren.
#
################################################################################
sub writeInstallLog {
	if (open(INSTALL_LOG_FILE, ">", "$installDir/$LOG_FILE_DIR/$INSTALL_LOG_FILE_NAME")) {
		foreach (@uninstallCommands) {
			printf(INSTALL_LOG_FILE "command: $_\n");
		}

		foreach (@filesCreated) {
			printf(INSTALL_LOG_FILE "created: $_\n");
		}

		close(INSTALL_LOG_FILE);
	}
}


################################################################################
#
# Ist das gegebene Programm installiert.
#
################################################################################
sub checkCommandExists {
	my $check = `sh -c 'command -v $_[0]'`;
	return $check;
}


################################################################################
#
# Herausfinden auf welchem OS wir wohl laufen.
#
################################################################################
sub detectOS {
	open my $file, '<', '/etc/os-release';
	my %hash = map { split /=/; } <$file>;
	close $file;

	my $result = $hash{"ID"};
	$result =~ s/["\s-]+//g;

	return $result;
}


################################################################################
#
# Prüfung ob eine Library installiert ist.
#
################################################################################
sub
checkLibsInstalled {
	my $command = $_[0];
	my $args    = $_[1];
	my @libs    = @{$_[2]};
	my @result;

	foreach (@libs) {
		my $lib = $_;
		if (system("$command $args $lib > /dev/null 2>&1") != 0) {
			push @result, $lib;
		}
	}

	return @result;
}


################################################################################
#
# Installiert potentiel fehlende Libraries
#
################################################################################
sub installLibraries {
	my $os = detectOS();

	if (exists($LIBRARIES_TO_INSTALL{$os})) {
#		print "$os: @{$LIBRARIES_TO_INSTALL{$os}}\n";
		my $installCommand = $LIBRARIES_TO_INSTALL{$os}[2];
		my $installArgs = $LIBRARIES_TO_INSTALL{$os}[3];

		my @libs = checkLibsInstalled($LIBRARIES_TO_INSTALL{$os}[0], $LIBRARIES_TO_INSTALL{$os}[1], \@{$LIBRARIES_TO_INSTALL{$os}[4]});

		if (checkCommandExists($installCommand) && scalar @libs != 0) {
			my $command = "sudo " . $LIBRARIES_TO_INSTALL{$os}[2] . " " . $LIBRARIES_TO_INSTALL{$os}[3] . " " . join(' ', @libs);

			if (yesNoAnswer(sprintf($TRANSLATABLE[24], $APPLICATION_NAME, $HPS_VER, join(', ', @libs), $command), 1)) {
				system($command);
			}
		}
#	} else {
#		print "$os not found\n";
	}
}


################################################################################
#
# Installiert eine ältere Version, für Systeme, die wir nicht mehr unterstützen
#
################################################################################
sub checkForLegacyVersion {
	my $machineType = `uname -m`;

	chomp($machineType);

	if ($machineType ne "x86_64"
		&& length($LEGACYVERSION_X32)) {
		if (yesNoAnswer(sprintf($TRANSLATABLE[25], $LEGACYVERSION_X32), 1)) {
			my $result = 1;
			my $file2get = $DOWNLOAD_SERVER."/".sprintf($LEGACY_VERSION_SERVER_PATH, $AFFILIATE_ID, $LEGACYVERSION_X32);

			printf($TRANSLATABLE[26], $LEGACYVERSION_X32);

			my $legacySubDir = "$APPLICATION_NAME $LEGACYVERSION_X32";
			$legacySubDir =~ s/ /_/g;

			my $legacyInstallerFileName = "$legacySubDir.tgz";

			mkdir($legacySubDir);
			chdir($legacySubDir);

			if ($verbose == 0) {
				$result = system("wget -q '$file2get' -O '$legacyInstallerFileName'");
			} else {
				$result = system("wget '$file2get' -O '$legacyInstallerFileName'");
			}

			if ($result == 0) {
				# Entpacke Installationspacket
				$result = system("tar xvzf $legacyInstallerFileName > /dev/null 2>&1");

				if ($result == 0) {
					# Starte Installationsscript
					my $args = "";

					if ($keepPackages == 1) {
						$args = $args." -k";
					}

					if ($installDir ne "") {
						$args = $args." -i ".$installDir;
					}

#					print("perl ./install.pl $args");
					$result = system("perl ./install.pl $args");

					if ($result == 0) {
						chdir("..");

						# Heruntergeladene Dinge wieder löschen
						if ($keepPackages == 0) {
							opendir(DIR, $legacySubDir);
							my @filesToRemove = readdir(DIR);
							close(DIR);
							foreach(@filesToRemove) {
								unlink("$legacySubDir/$_");
							}
							rmdir($legacySubDir);
						}

						exit 0;
					} else {
						printf($TRANSLATABLE_ERRORS[20], $LEGACYVERSION_X32);
					}
				} else {
					printf($TRANSLATABLE_ERRORS[9], $legacyInstallerFileName);
				}
			} else {
				printf($TRANSLATABLE_ERRORS[19], $LEGACYVERSION_X32);
			}
		}

		exit 1;
	}
}

################################################################################
#
# MAIN
#
################################################################################
# Erzwinge eine Leerung der Puffer nach jeder print()-Operation
$| = 1;

system("clear");

if (basename($0) eq $PROGRAM_NAME_UNINSTALLER) {
	getOptions();
	uninstall();

} else {
	# loadTranslations();
	# getOptions();
	# checkForLegacyVersion();
	# printf($TRANSLATABLE[4], $APPLICATION_NAME, $HPS_VER);
	checkWorkingDir();
	checkProgramms();
	showEula();
	getInstallDir();
	getIndexFile();
	checkIndexFile();
	downloadFiles();
	stopAutoBookService();
	unpackFiles();
	finalizeInstallation();
	installLibraries();
	createIcons();
	createMimeType();
	createDesktopShortcuts();
	registerExecutables();
	writeInstallLog();
	startAutoBookService();
	cleanup();
	# triggerCountPixel($INSTALLATION_COMPLETE_URL);

	my $executablePath = $installDir . "/" . $APPLICATION_NAME;
	$executablePath =~ s/\/+/\//g;
	printf($TRANSLATABLE[12], $APPLICATION_NAME, $HPS_VER, $executablePath);
}
