# install-host
Ansible install host playbook for Debian

### Этапы подготовки Debian 10 для установки Ansible
Создания пользователя Ansible sudo
``` 
su root
# Install package sudo
apt-get install -y sudo

# Add ansible user
/sbin/adduser ansible

# Add ansible user to sudo group
/sbin/adduser ansible sudo

# Install requered package
apt-get install -y python-apt
```

### Установка Ansible
Проверить установлен ли Python 3
```
python3 --version
```
При необходимости установить Python3+Pip+Virtualenv 
* Установка Python 3 

Создаем в домашнем каталоге директорий ansible и устанавливаем туда новое виртуальное окружение 
```
# создаем каталог для виртуального окружения
mkdir ansible
cd ./ansible
# создаем окружение
python3 -m venv env
# активируем виртуальное окружение 
source ~/ansible/env/bin/activate
# установливаем пакет wheel необходимый ansible
pip3 install wheel
# устанавливаем ansible
pip3 install ansible
```
Далее необходимо создать:

### Конфигурационный файл Ansible.cfg
Конфигурационный файл Ansible может храниться в разных местах (файлы перечислены в порядке уменьшения приоритета):
ANSIBLE_CONFIG (переменная окружения)
ansible.cfg (в текущем каталоге)
.ansible.cfg (в домашнем каталоге пользователя)
/etc/ansible/ansible.cfg

Создадим конфигурационный файл в домашнем каталоге ~/ansible:
```
[defaults]
inventory = ~/ansible/.hosts
remote_user = ansible
vault_password_file = ~/vault.key

[ssh_connection]
pipelining = true
```
ВАЖНО:  Необходима установка параметра pipelining для корректной работы модуля postgresql_user

### Файл Inventory .hosts
Содержит информацию об удаленных хостах и способах подключения к ним
```
[webervers]
192.168.89.244 ansible_ssh_private_key_file=~/ansible/.ssh/ansible
```
Параметры:
```
ansible_ssh_private_key_file=~/ansible/.ssh/ansible путь к файлу с приватным ключём при SSH 
```

### Настройка SSH доступа
* Как прописать SSH-ключ пользователя
Чтобы заходить на удаленные машины, пользователь username должен создать пару из закрытого/открытого RSA ключа. 

Создание SSH ключей: 
```$ ssh-keygen -t rsa```
Дополнительно указать расположение и имя файла с RSA ключом (в примере ниже файл ключа с именем ansible)
```
Enter file in which to save the key (/home/username/.ssh/id_rsa): ./.ssh/ansible
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in ./.ssh/ansible
Your public key has been saved in ./.ssh/ansible.pub
```
Если предполагается, что команды Ansible будут выполняться под пользователем ansible удаленной машины, то пользователь username должен уметь заходить на удаленную машину как ansible по ssh. Чтобы можно было это делать без постоянного ввода пароля, нужно под пользователем usernameскопировать сгенерированный публичный ключ:

Копирование созданного публичного RSA ключа на удаленный хост можно сделать командой: 

```$ ssh-copy-id -i ~/.ssh/ansible.pub ansible@remoteHost```

Чтобы этот механизм работал, нужно проверить файлы конфигурации SSH-сервера. 
Это надо делать на удаленной машине. В файле /etc/ssh/sshd_config надо убрать комментарии перед строками 
RSAAuthentication yes (данный параметр необходимо добавить, его нет в конфигурационном файле), PubkeyAuthentication yes и AuthorizedKeysFile.ssh/authorized_keys. 

После чего следует перезапустить SSH-сервер на удаленной машине: 

```sudo /etc/init.d/ssh restart```

### Установка SSH-Pass
Для возможности запускать ansible-playbook по SSH паролю необходимо установить пакет SSHPass:

```sudo apt-get install sshpass```

### Обращение к закрытым репозиториям Git по SSH
Для возможности доступа к репозиториям необходимо:

* иметь учетную запись на GitНub
* иметь публичный ключ SSH, связанный с вашей учетной записью на GitНub

Для генерации можно воспользоваться сценарием Как прописать SSH-ключ пользователя или воспользоваться ansible-playbook сценарием:

```
# Generate ssh keys if it is not yet.
# Send ssh key name as command line parameter to generate keys
# Generated keys will write into ~/.ssh directory
# command line simple: ./generate-ssh-key.sh github_dimag_rsa

./utils/generate-ssh-key.sh github_dimag_rsa
```
Сгенерированный SSH ключ рекомендуется сохранить в lastpass Как хранить SSH ключи в LastPass 

Этот ключ необходимо добавить ключ в репозиторий GitHub:
* Запустить SSН-агента на управляющей машине с включенным агентом перенаправления
```eval `ssh-agent -s````
* добавить свой ключ SSH в SSН-агента
```
# добавление ключа
ssh-add ~/.ssh/*_rsa
# проверить добавился ли ключ
ssh-add -l
4096 SHA256:TuFVu2sdJjdgK55jkfjhsdhhtgtyTm2/k ansible-generated on ansible (RSA)
```
Чтобы включить агента перенаправления, нужно добавить следующие строки в файл
 ```
[ssh_connection]
ssh_args = -о ControlMaster=auto -о ControlPersist=60s -о ForwardAgent=yes
```
Нелишним также будет убедиться в домтупности сервера GitHub по SSH, выполнив команду:
```
ssh -T git@github.com
Hi <name>! You've successfully authenticated, but GitHub does not provide shell access.
```
