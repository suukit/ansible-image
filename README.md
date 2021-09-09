ansible
===========

Ansilbe im Docker
-----------------

Um Ansible auf unterschiedlichen Servern nicht pflegen zu müssen, stellen wir einen Container zur Verfügung.
Dieser bringt ein voll funktionsfähiges Ansible mit.

Die Verwendung ist identisch zu einem lokal installierten Ansible.

### Setup und Update
Alle Ansible-Befehle werden unter /home/\<user>/bin abgelegt.
Bitte Installationshinweise befolgen!
```
docker run --rm ansible-image
```

### Ansible verwenden
Jeder Ansible-Befehl startet einen Container mit entsprechenden Ansible-Kommando. Die Parameter sind mit den "echten" Ansible-Parametern identisch.
```
ansible-playbook playbooks/Beispiel.yaml
```

### Vaults
Wir empfehlen die Verwendung einer ```ansible.cfg```, welcher im **aktuellen** Verzeichnis liegen muss.

Ist in dieser Datei ein ```vault_password_file``` definiert, wird dieses automatisch in den Container gemountet.

Alternativ kann über eine Ugebungsvariable der Vault definiert werden:
```
export ANSIBLE_VAULTPASSWORDFILE=/path/to/file
```

### Zusätzliche Mounts
Mit Leerzeichen getrenne Liste aus aus Volume-Parametern
```
export ANSIBLE_MOUNTS=/lokal:/docker /lo:/do
```


## Build - Ansible
```
./buildAnsible.sh

... testen ...

```
