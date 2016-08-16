To generate an autoinstall image for Ubuntu:
- In the `preseed/` directory, create these files:
  - `root.passwd` - the contents should be a plaintext password that will be
    used for the root account. (a hash of the password is stored on the
    image, not the password itself). If this file doesn't exist, the root
    password will be disabled.
  - `root.ssh` - this gets installed as `/root/.ssh/authorized_keys`, so it
    should contain public keys for ssh identities that should be able to access
    the root account. If this file doesn't exist, no `authorized_keys` file is
    installed.
  - `scion.passwd` - same as `root.passwd`, for the scion user account.
  - `scion.ssh` - installed as `/home/scion/.ssh/authorized_keys`, just like
    for root.
  - NOTE: If you provide none of these, you will not be able to log into the
    installed machine!
- (Optional) Edit the config file (`xenial.cfg` etc) and change the `d-i
  mirror/http/hostname` entry  to use your local Ubuntu mirror.
- Run the build script in the `preseed/` directory:

  `./mkmini.sh`

  By default, the script will build an ISO based on Ubuntu 16.04 (Xenial
  Xerus), but you can specify another Ubuntu codename as the first argument:

  `./mkmini.sh trusty`

  Note that you will have to have the corresponding config file.
- This will generate `build/scion-codename.iso`. This image can be burnt to a
  CD, or directly dd'd onto a usb drive:

  `sudo dd if=build/scion-xenial.iso of=/dev/sde bs=16M conv=nocreat`
  (this example assumes the usb drive is at `/dev/sde`).
- The installer will automatically boot after 15s (configurable via
  `timeout` in `txt.cfg`), and will pause at the end for the install media to
  be removed.
- If you want to test the installer inside VirtualBox, you can create a vbox
  image with this command:

  `VBoxManage internalcommands createrawvmdk -rawdisk $PWD/build/scion-xenial.iso -filename build/scion-xenial.vmdk`

  The resulting `build/scion-xenial.vmdk` image can be attached to any vbox
  instance. Note that it refers to `scion-xenial.iso` as the underlying 'block'
  device, so any changes to `scion-xenial.iso` will be seen by virtualbox.
