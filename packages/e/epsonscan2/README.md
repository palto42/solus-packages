# Epson Scan 2

## Download

Homepage: [Epson Scan 2](https://support.epson.net/linux/en/epsonscan2.php)

[Epson Scan 2 Manual](https://download.ebz.epson.net/man/linux/epsonscan2_e.html)

Check version on driver page for Epson XP-7100
`https://download.ebz.epson.net/dsc/search/01/search/searchModule?productName=xp-7100&osCode=LX`

Get latest direct download link with the command:

```console
curl -s -I 'https://download.ebz.epson.net/dsc/du/02/DriverDownloadInfo.do?LG2=JA&CN2=US&CTI=171&PRN=Linux%20src%20package&OSC=LX&DL' | grep Location | sed -n "s/Location: //p"
```

The output contains the direct link in the "Location" line.

```console
https://download3.ebz.epson.net/dsc/f/03/00/14/53/67/1a6447b4acc5568dfd970feba0518fabea35bca2/epsonscan2-6.7.61.0-1.src.tar.gz
```

## User Manual

[EpsonScan2 User Manual](https://download.ebz.epson.net/man/linux/epsonscan2_e.html)
