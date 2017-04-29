##### Preparation

1. Get zip archive: [Master](https://git.tuxico.com/arch-installer/snapshot/arch-installer-master.zip)
2. Extract archive: `unzip arch-installer-master.zip`
3. Edit configuration: `arch-installer-master/ali/conf/YourPcName.conf`
4. Edit your machine name:`PC='YourPcName'` in `arch-installer-master/ali/ali.sh`
5. Create new installer archive: `cd arch-installer-master && tar czf ali.tar.gz ali/`
6. Upload your new archive `ali.tar.gz` on your FTP.

##### Installation

```
wget <ftp-url>/ali.tar.gz && tar xzf ali.tar.gz
cd ali && chmod +x ali.sh
./ali.sh -i
```

Or

```
curl -O https://git.tuxico.com/arch-installer/snapshot/arch-installer-master.tar.gz
tar xzf arch-installer-master.tar.gz
mv arch-installer-master/ali /root
```

##### FHS Installation

    ali/
    ├── ali.sh               *
    ├── conf
    │   ├── apps.conf        *
    │   ├── dot
    │   │   ├── bash_aliases
    │   │   ├── bash_profile
    │   │   └── bashrc
    │   └── hp.conf          *
    ├── libs
    │   ├── lib-core.sh
    │   ├── lib-desktop.sh
    │   ├── lib-devel.sh
    │   ├── lib-install.sh
    │   ├── lib-pacman.sh
    │   ├── lib-sys.sh
    │   ├── lib-users.sh
    │   ├── lib-utils.sh
    │   └── lib-xorg.sh
    └── utils                **
        ├── aur.sh           **
        └── wipe.sh          **

***
\* Check parameters required -- \*\* File not Required

