## Evaluation environment setup

- address in zerotier: 172.22.22.22

- login `ssh your-user-name@172.22.22.22`

- choose unused ports between 10000-49151. to check all ports in use, run `ss -tulnp`
add the following lines to the end of your `~/.bashrc`
```bash
export WEBTOP_SSH_PORT=choose-an-ssh-port
export WEBTOP_GUI_PORT=choose-a-gui-port
export WEBTOP_PASSWORD=choose-your-password
```
then
```
source ~/.bashrc
```

- in your home directory `/home/your-user-name/`
```bash
mkdir webtop-home
cd webtop-home
echo "export XILINXD_LICENSE_FILE=/opt/Xilinx/Xilinx.lic" >> .bashrc
echo "export LD_PRELOAD="/lib/x86_64-linux-gnu/libudev.so.1 /lib/x86_64-linux-gnu/libselinux.so.1 /lib/x86_64-linux-gnu/libz.so.1 /lib/x86_64-linux-gnu/libgdk-x11-2.0.so.0"" >> .bashrc
echo "export PATH="/opt/bin:/opt/riscv/bin:/opt/Xilinx/Vivado/2024.2/bin/:$HOME/.local/bin:$PATH"" >> .bashrc
echo "source ~/.bashrc" >> .profile
```

- run the following script to start your docker container
```bash
vivado-docker.sh start
```

- for gui, access https://172.22.22.22:your-gui-port in your browser (chromium based is recommended)
  - use your username and WEBTOP_PASSWORD to login

- for ssh, see the example config `~/.ssh/config`
```
Host vivado
    HostName 172.22.22.22
    User abc
    Port your-ssh-port
    # IdentityFile ~/.ssh/your-key # optional if you set up an ssh key
```
the default password for ssh login to the docker is `abc`

- the home directory in the container is `/config`, which is bind to `/home/your-user-name/webtop-home` outside the container