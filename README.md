# Task Manager - EN

## Description

This project is a **Task Manager** developed in **Bash**, designed for monitoring and managing system processes and resources. The application allows the user to view resource usage in real time, manage processes, and perform various operations on them.

## Features

- **Interactive menu** for easy use
- **Resource monitoring**:
  - RAM & Hard Disk
  - CPU
  - Network usage
  - Active, suspended, sleeping, and orphan processes
- **Process operations**:
  - Display all active processes
  - Start a new process
  - Suspend an existing process
  - Resume a suspended process
  - Terminate a process
  - Wait for a process (or all processes) to finish
  - Move a process to background/foreground
  - Restrict termination of multiple processes
  - List restricted processes
  - Remove processes from the restricted termination list
  - Stop processes for a specific user
- **Resource configuration**:
  - Enable IP Forwarding
  - Disable IP Forwarding
  - Set memory usage (vm.swappiness)
  - Enable kernel logs (debug)
  - Disable kernel logs (debug)
- **Generating a top list** of the most resource-consuming processes, saving a report in `top_processes.log`
- **Saving logs** (`out.log` file) in a local repository to track versions over time
- **Using getopt** for command-line argument interpretation (manual parsing is not allowed)

## Requirements

- Linux operating system
- Bash shell
- Standard Linux commands (`top`, `htop`, `ps`, `sed`, `awk`, `grep`, etc.)

## Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/alexutzzro/TaskManager.git
   cd TaskManager
   ```

2. **Grant execution permissions:**
   ```bash
   chmod +x TaskManager.sh
   ```

## Usage

To run the application, execute:
```bash
./TaskManager.sh
```
Then, select the available options from the interactive menu.

## Logging

Each execution of the script generates logs that are:
- Displayed in **STDOUT/STDERR**
- Saved in the `out.log` file
- Optionally uploaded to the cloud (e.g., via Git)

## License

This project was developed as part of the **Operating Systems 1** course at the Faculty of Mathematics and Computer Science, West University of Timișoara.

---

# Task Manager - RO

## Descriere

Acest proiect este un **Task Manager** realizat în **Bash**, destinat monitorizării și gestionării proceselor și resurselor sistemului. Aplicatia permite utilizatorului să vadă utilizarea resurselor în timp real, să gestioneze procese și să efectueze diverse operații asupra acestora.

## Caracteristici

- **Meniu interactiv** pentru utilizare ușoară
- **Monitorizare resurse**:
  - RAM & Hard Disk
  - CPU
  - Utilizarea rețelei
  - Procese active, suspendate, in sleep, orfane
- **Operații cu procese**:
  - Afișarea tuturor proceselor active
  - Pornirea unui nou proces
  - Suspendarea unui proces existent
  - Reactivarea unui proces suspendat
  - Terminarea unui proces
  - Așteptarea unui proces (terminării tuturor proceselor)
  - Trecerea unui proces în background/foreground
  - Restricționare terminare procese multiple
  - Lista proceselor restricționate de la terminare
  - Ștergerea proceselor din lista restricționată de la terminare
  - Oprire procese pentru un anumit utilizator
- **Configurarea resurselor**:
  - Activare IP Forwarding
  - Dezactivare IP Forwarding
  - Seteaza utilizarea memoriei (vm.swappiness)
  - Activeaza loguri de kernel (debug)
  - Dezactiveaza loguri de kernel (debug)
- **Generarea unui top** cu procesele care consumă cele mai multe resurse, generând un raport salvat în `top_processes.log`
- **Salvarea** logurilor (fișierul `out.log`) într-un repository local, pentru a putea vedea în timp versiunile acestui fișier
- **Utilizarea getopt** pentru interpretarea argumentelor din linia de comandă (nu se acceptă parsarea manuală a argumentelor)

## Cerințe

- Sistem de operare Linux
- Shell Bash
- Comenzi standard Linux (`top`, `htop`, `ps`, `sed`, `awk`, `grep` etc.)

## Instalare

1. **Clonare repository:**
   ```bash
   git clone https://github.com/alexutzzro/TaskManager.git
   cd TaskManager
   ```

2. **Acordare permisiuni de execuție:**
   ```bash
   chmod +x TaskManager.sh
   ```

## Utilizare

Pentru a rula aplicația, executați:
```bash
./TaskManager.sh
```
Ulterior, selectați opțiunile disponibile din meniul interactiv.

## Logare

Fiecare execuție a scriptului generează log-uri care sunt:
- Afișate în **STDOUT/STDERR**
- Salvate în fișierul `out.log`
- Opțional, urcate în cloud (de exemplu, prin Git)

## Licență

Acest proiect a fost realizat în cadrul disciplinei **Sisteme de Operare 1** din cadrul Facultății de Matematică și Informatică, Universitatea de Vest din Timișoara.
