##### Preparation

1. Get zip archive: [Master](http://git.tuxico.com/arch-installer.git/zipball/master)
2. Extract archive: `unzip master -d arch-installer`
3. Edit configuration: `arch-installer/ali/conf/YourPcName.conf`
4. Edit your machine name:`PC='YourPcName'` in `arch-installer/ali/ali.sh`
5. Create new installer archive: `cd arch-installer && tar czf ali.tar.gz ali/`
6. Upload your new archive `ali.tar.gz` on your FTP. Ex: [http://arch.tuxico.com/ali/ali.tar.gz](http://arch.tuxico.com/ali/ali.tar.gz)

##### Installation

```
wget <ftp-url>/ali.tar.gz && tar xzf ali.tar.gz
cd ali && chmod +x ali.sh
./ali.sh -i

```

Or

```
curl -u user:pass -O git.tuxico.com/arch-installer.git/tarball/master
mkdir installer && tar xf master -C installer/
mv installer/ali /root
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
        ├── hdd.py           **
        ├── aur.sh           **
        └── tests.sh         **

***
\* Check parameters required -- \*\* File not Required

