cd ~

# Клонируем репозиторий с исходниками.
git clone https://github.com/maxstarkov/lavg.git

# Создаем структуру каталогов для сборки пакета.
rpmdev-setuptree

# Временный каталог для сборки архива исходников.
mkdir /tmp/lavg-0.1

# Копируем во временный каталог нужные файлы исходников.
cp lavg/lavg.py lavg/LICENSE /tmp/lavg-0.1/

cd /tmp/

# Создаем архив исходников для подготовки rpm пакета.
tar -cvzf lavg-0.1.tar.gz lavg-0.1

# Перемещаем готовый архив в каталог исходников.
mv lavg-0.1.tar.gz ~/rpmbuild/SOURCES/

cd ~

# Копируем из репозитория spec файл на основании которого будет сборан rpm пакет.
cp lavg/lavg.spec ~/rpmbuild/SPECS/

cd ~/rpmbuild/SPECS/

# Запускаем сборку srpm пакета.
rpmbuild -bs lavg.spec

# На основе srpm пакета сбираем бинарный пакет - обычный rpm.
rpmbuild --rebuild ~/rpmbuild/SRPMS/lavg-0.1-1.el7.src.rpm

# Установим в системе готовый пакет.
rpm -i ~/rpmbuild/RPMS/noarch/lavg-0.1-1.el7.noarch.rpm