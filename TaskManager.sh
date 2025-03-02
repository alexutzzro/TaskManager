#!/bin/bash

# Proiect -- Tematica: Task Manager

# Configurarea fisierului "out.log" pentru a memora
# toate interactiunile utilizatorului cu programul
logfile="out.log"
exec > >(tee -a "$logfile") 2>&1

# Aceasta functie salveaza fisierul 'out.log' intr-un repository Git local.
# Verifica daca exista un repository Git in folderul curent; daca nu, creeaza unul nou.
# Seteaza email-ul si numele utilizatorului Git doar pentru acest repository (local).
# Verifica daca fisierul 'out.log' exista. Daca nu, afiseaza un mesaj de eroare si opreste procesul.
# Adauga fisierul 'out.log' in repository si creeaza un commit cu data si ora curenta (date preluate din sistem).
function salveaza_pe_git() {
    echo "=== Salvare $logfile in repository Git ==="

    # Se verifica existenta unui repo Git in folderul curent
    if [ ! -d .git ]; then
        echo "Repository-ul Git nu exista aici. Realizez un repository local..."
        git init
        echo "Repository-ul Git a fost initializat cu succes!"
    fi

    # Configurare utilizator Git (local, doar pentru acest repo)
    GIT_EMAIL="iosif.nagy04@e-uvt.ro"
    GIT_NUME="Alexandru Nagy"
    git config user.email $GIT_EMAIL
    git config user.name $GIT_NUME

    # Afisare mesaj pentru ca utilizatorul care ruleaza programul 
    # sa cunoasca ce utilizator a fost initializat pentru folosirea cu Git
    echo "Config utilizator Git: $GIT_NUME ($GIT_EMAIL)"

    # Se verifica daca fisierul out.log (variabila logfile) exista
    if [ ! -f "$logfile" ]; then
        echo "Eroare! Fisierul $logfile nu exista si nu poate fi adaugat in Git."
        return
    fi

    # Se adauga fisierul out.log in repo Git local
    git add "$logfile"

    # Realizam un commit cu un mesaj distinctiv care preia din sistem data si ora folosind comanda 'date'
    git commit -m "Actualizare log $(date '+%Y-%m-%d %H:%M:%S')"

    # Mesaj de instiintare cu privire la operatiunea realizata
    echo "Fisierul $logfile a fost salvat in repository-ul local Git."
}

# Aceasta functie afiseaza meniul principal in momentul executarii pentru prima data a programului
# Meniul este realizat prin intermediul comenzii select
function meniu_principal() {
    echo "=== Task Manager ==="
    select opt in "Monitorizare resurse" "Procese" "Configurare resurse" "Top procese" "Salveaza $logfile in Git" "Iesire"; do
        case $REPLY in
            1) monitorizare_resurse ;;
            2) gestiune_procese ;;
            3) configurare_resurse ;;
            4) top_procese ;;
            5) salveaza_pe_git ;;
            6) exit 0 ;;
            *) echo "Optiune invalida!" ;;
        esac
    done
}

# Aceasta functie monitorizeaza resursele sistemului la un interval de timp specificat de utilizator.
# Solicita un interval de timp de la utilizator (exemplu: 5s pentru 5 secunde, 10m pentru 10 minute).
# Verifica formatul intervalului pentru a se asigura ca este corect.
# Afiseaza periodic urmatoarele informatii:
#  - Utilizarea memoriei RAM (total si utilizata);
#  - Spatiul pe disc (total si utilizat);
#  - Utilizarea CPU (in procente);
#  - Utilizarea retelei (daca comanda 'ifstat' este disponibila);
#  - Numarul de procese in stari diferite (active, suspendate, in sleep, orfane);
# Repeta monitorizarea la fiecare interval specificat pana cand este intrerupta de utilizator, prin intermedul CTRL + C .
function monitorizare_resurse() {
    echo -n "Introdu timestamp-ul pentru actualizare (exemplu: 5s, 10m, 1h): "
    read -r timestamp
    
    # Se verifica daca timestamp-ul este in formatul corespunzator.
    if [[ ! $timestamp =~ ^[0-9]+[smh]$ ]]; then
        echo "Format invalid! Introdu un numar urmat de s (secunde), m (minute), h (ore)."
        echo "Exemplu: '5s' pentru 5 secunde, '10m' pentru 10 minute."
        return
    fi

    echo "Monitorizare resurse sistem la fiecare $timestamp..."
    while true; do
        echo "=== Resurse ==="
        
        echo "Memorie RAM: $(free -h | grep Mem | awk '{print $3 "/" $2}')"         # Monitorizare memorie RAM
        echo "Spatiu pe HDD/SSD: $(df -h / | awk 'NR==2 {print $3 "/" $2}')"        # Monitorizare spatiu liber pe HDD/SSD
        echo "CPU: $(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')% utilizat"   # Monitorizare CPU (procente)

        # Informatii despre utilizarea retelei de internet (placa de retea)
        if command -v ifstat > /dev/null; then
            echo "Utilizare retea: $(ifstat -t 1 1 | tail -n1)"
        else
            echo "Utilizare retea: Comanda 'ifstat' nu este disponibila. Folositi 'sudo apt-get install ifstat' pentru instalare!"
        fi

        total_active=$(ps aux | wc -l)                                      # Total procese active
        total_suspendate=$(ps -eo stat | grep '^T' | wc -l)                 # Total procese suspendate
        total_sleep=$(ps -eo stat | grep '^S' | wc -l)                      # Total procese in sleep
        total_orfane=$(ps -eo pid,ppid | awk '$2 == 1 {print $1}' | wc -l)  # Total prcese orfane

        echo "Procese:"
        echo "  - Active: $total_active"
        echo "  - Suspendate: $total_suspendate"
        echo "  - In sleep: $total_sleep"
        echo "  - Orfane: $total_orfane"

        sleep "$timestamp"
    done
}

# Acesta functie afiseaza submeniul de la optiunea 2 din meniul principal
# Sunt afisate optiunile disponibile din categoria "Procese"
function gestiune_procese() {
    echo "=== Procese ==="
    select opt in "Listare procese active" "Startare proces" "Suspendare proces" "Reactivare proces" "Terminare proces" "Asteptare procese" "Background/Foreground" "Restrictionare terminare procese multiple" "Lista proceselor restrictionate de la terminare" "Sterge procese din lista restrictionata de la terminare" "Oprire procese pentru un anumit utilizator" "Inapoi"; do
        case $REPLY in
            1) ps -aux ;;               # Se afiseaza lista tuturor proceselor active
            2) startare_proces ;;
            3) suspenda_proces ;;
            4) reactiveaza_proces ;;
            5) terminare_proces ;;
            6) wait ;;                  # Se va astepta ca toate procesele din fundal initiate de script sa se termine
            7) back_fore ;;
            8) restrictie_proces ;;
            9) lista_restrictii ;;
            10) elimina_restrictie ;;
            11) oprire_proces_utilizator ;;
            12) break ;;
            *) echo "Optiune invalida!" ;;
        esac
    done
}

# Aceasta functie permite utilizatorului sa lanseze un proces nou.
# Solicita utilizatorului sa introduca o comanda pentru a lansa procesul dorit.
# Ruleaza comanda specificata in fundal folosind simbolul '&'.
# Salveaza PID-ul procesului lansat si il afiseaza pentru utilizator.
function startare_proces() {
    echo "Introdu comanda pentru procesul pe care doriti sa-l porniti:"
    read -r comanda

    # Lansam procesul
    $comanda &
    pid=$!
    echo "Procesul cu PID $pid a fost lansat."
}

# Aceasta functie permite suspendarea unui proces specificat de utilizator.
# Solicita utilizatorului sa introduca PID-ul procesului care trebuie suspendat.
# Verifica daca procesul cu PID-ul specificat exista folosind comanda 'ps'.
# Daca procesul exista, trimite semnalul 'STOP' catre proces pentru a-l suspenda.
# Informeaza utilizatorul daca suspendarea a fost efectuata cu succes sau daca a aparut o eroare.
function suspenda_proces() {
    echo "Introdu PID-ul procesului pe care vrei sa-l suspenzi: "
    read -r pid

    # Verificam daca procesul exista (PID)
    if ! ps -p "$pid" > /dev/null 2>&1; then
        echo "Eroare! Procesul cu PID $pid nu exista."
        return
    fi

    # Suspendam procesul
    kill -STOP "$pid"
    if [[ $? -eq 0 ]]; then
        echo "Procesul $pid a fost suspendat cu succes."
    else
        echo "Eroare! Nu s-a putut suspenda procesul $pid."
    fi
}

# Aceasta functie permite reactivarea unui proces suspendat.
# Solicita utilizatorului sa introduca PID-ul procesului care trebuie reactivat.
# Verifica daca procesul cu PID-ul specificat exista folosind comanda 'ps'.
# Daca procesul exista, trimite semnalul 'CONT' pentru a continua executia procesului suspendat.
# Informeaza utilizatorul daca reactivarea a fost efectuata cu succes sau daca a aparut o eroare.
function reactiveaza_proces() {
    echo "Introdu PID-ul procesului pe care vrei sa-l reactivezi: "
    read -r pid

    # Verificam daca procesul exista (PID)
    if ! ps -p "$pid" > /dev/null 2>&1; then
        echo "Eroare! Procesul cu PID $pid nu exista."
        return
    fi

    # Reactivam procesul
    kill -CONT "$pid"
    if [[ $? -eq 0 ]]; then
        echo "Procesul $pid a fost reactivat cu succes."
    else
        echo "Eroare! Nu s-a putut reactiva procesul $pid."
    fi
}

# Aceasta functie permite mutarea unui proces intre foreground si background folosind fg si bg.
# FUNCTIONEAZA DOAR CU comanda 'source', deoarece:
# - 'source' executa scriptul in shell-ul curent, unde job-urile sunt controlabile (job control).
# - Cand rulezi scriptul cu './script.sh', acesta ruleaza intr-un subshell, iar job control-ul (comenzile fg/bg) nu functioneaza in shell-ul parinte.
# Daca scriptul este rulat cu './script.sh', comenzile fg si bg vor genera eroarea "no job control".
function back_fore() {
    echo "Introdu comanda pentru procesul pe care doriti sa-l rulati:"
    read -r comanda

    # Lansam procesul
    eval "$comanda" &
    pid=$!
    echo "Procesul cu PID $pid a fost lansat."

    select actiune in "Trecere in background" "Aducere in foreground" "Iesire"; do
        case $REPLY in
            1)
                # Trecere in background
                echo "Mutam procesul in background..."
                bg %+
                echo "Procesul a fost mutat in background."
                ;;
            2)
                # Aducere in foreground
                echo "Mutam procesul in foreground..."
                fg %+
                echo "Procesul a fost adus in foreground."
                ;;
            3)
                # Iesire
                break
                ;;
            *)
                echo "Optiune invalida!"
                ;;
        esac
    done
}

# Variabila globala pentru PID-uri restrictionate
declare -a piduri_restrictionate=()


# Aceasta functie permite adaugarea unor procese intr-o lista de restrictii pentru terminare.
# Solicita utilizatorului sa introduca unul sau mai multe PID-uri ale proceselor ce trebuie restrictionate, separate prin spatiu.
# Adauga fiecare PID introdus in lista 'piduri_restrictionate'.
# Informeaza utilizatorul pentru fiecare proces adaugat in lista de restrictii.
function restrictie_proces() {
    echo "Introdu PID-urile proceselor de restrictionat (separate prin spatiu):"
    read -r -a piduri
    for pid in "${piduri[@]}"; do
        piduri_restrictionate+=("$pid")
        echo "PID-ul $pid a fost adaugat in lista proceselor restrictionate pentru terminare."
    done
}


# Aceasta functie permite terminarea unui proces specificat de utilizator.
# Solicita utilizatorului sa introduca PID-ul procesului care trebuie terminat.
# Verifica daca procesul specificat este in lista de restrictii 'piduri_restrictionate'.
# Daca procesul este restrictionat, afiseaza un mesaj de eroare si nu continua terminarea.
# Daca procesul nu este restrictionat, trimite semnalul 'SIGKILL' (comanda 'kill -9') pentru a-l termina fortat.
# Informeaza utilizatorul daca procesul a fost terminat cu succes.
function terminare_proces() {
    echo -n "Introdu PID-ul procesului de terminat: "
    read -r pid

    # Se verifica daca PID-ul este in lista PID-urilor restrictionate
    if [[ " ${piduri_restrictionate[*]} " =~ " $pid " ]]; then
        echo "Eroare! Procesul $pid este restrictionat si nu poate fi terminat."
    else
        kill -9 "$pid" && echo "Procesul $pid a fost terminat."
    fi
}

# Aceasta functie afiseaza lista proceselor care sunt restrictionate de la terminare (din lista 'piduri_restrictionate' -- daca exista).
function lista_restrictii() {
    echo "PID-uri restrictionate: ${piduri_restrictionate[*]}"
}

# Aceasta functie permite eliminarea unui proces din lista de restrictii.
# Solicita utilizatorului sa introduca PID-ul procesului care trebuie eliminat din lista de restrictii.
# Verifica si elimina PID-ul specificat din lista 'piduri_restrictionate'.
# Informeaza utilizatorul ca restrictia pentru procesul respectiv a fost eliminata.
function elimina_restrictie() {
    echo "Introdu PID-ul de eliminat din lista de restrictii:"
    read -r pid
    piduri_restrictionate=("${piduri_restrictionate[@]/$pid}")
    echo "Restrictia pentru procesul $pid a fost eliminata."
}

# Aceasta functie permite oprirea tuturor proceselor care apartin unui utilizator specificat.
# Solicita utilizatorului sa introduca numele utilizatorului ale carui procese trebuie oprite.
# Verifica daca utilizatorul specificat exista, folosind comanda 'id'.
# Cere confirmarea utilizatorului inainte de a opri procesele (confirmare cu "da" sau "nu").
# Utilizeaza comanda 'pkill -u' pentru a opri toate procesele asociate utilizatorului specificat.
# Informeaza utilizatorul despre succesul operatiei sau despre eventualele erori (de exemplu, permisiuni insuficiente).
function oprire_proces_utilizator() {
    echo "Introdu numele utilizatorului ale carui procese doresti sa le opresti:"
    read -r utilizator

    # Se verifica existenta utilizatorului
    if ! id "$utilizator" > /dev/null 2>&1; then
        echo "Eroare! Utilizatorul $utilizator nu exista."
        return
    fi

    echo "Esti sigur ca doresti sa opresti toate procesele utilizatorului $utilizator? (da/nu)"
    read -r confirmare
    if [[ "$confirmare" != "da" ]]; then
        echo "Operatia a fost anulata!"
        return
    fi

    # Procesul de oprire al proceselor utilizatorului
    pkill -u "$utilizator"
    if [[ $? -eq 0 ]]; then
        echo "Toate procesele utilizatorului $utilizator au fost oprite!"
    else
        echo "Eroare! Nu s-au putut opri procesele utilizatorului $utilizator. Permisiune insuficienta!"
    fi
}

# Aceasta functie permite configurarea unor resurse esentiale ale sistemului.
# Ofera utilizatorului un meniu cu mai multe optiuni de configurare:
# 1. Activare IP Forwarding: 
#    - Permite redirectionarea traficului de retea prin setarea 'net.ipv4.ip_forward' din fisierul '/etc/sysctl.conf'.
# 2. Dezactivare IP Forwarding: 
#    - Se seteaza 'net.ipv4.ip_forward' din fisierul '/etc/sysctl.conf' la valoarea 0 (false).
# 3. Setare utilizare memorie (optiune: vm.swappiness):
#    - Permite utilizatorului sa seteze o valoare intre 0 si 100 pentru 'vm.swappiness', care controleaza cat de agresiv este kernelul in utilizarea memoriei swap.
# 4. Activare loguri de kernel (debug):
#    - Activeaza loguri detaliate ale kernelului prin modificarea valorii 'kernel.printk'.
# 5. Dezactivare loguri de kernel (debug):
#    - Se dezactiveaza logurile de kernel prin setarea valorii 'kernel.printk' la '4 4 1 7' (nivel standard de logare mai putin detaliat).
# Modificarile sunt aplicate in timp real folosind comanda 'sudo sysctl -p' (drepturi root).
# Verifica input-ul utilizatorului pentru validitate (exemplu: valoare intre 0 si 100 pentru 'vm.swappiness').
function configurare_resurse() {
    echo "=== Configurare resurse ==="
    select opt in "Activeaza IP Forwarding" "Dezactiveaza IP Forwarding" "Seteaza utilizarea memoriei (vm.swappiness)" "Activeaza loguri de kernel (debug)" "Dezactiveaza loguri de kernel (debug)" "Iesire"; do
        case $REPLY in
            1)
                # Activare IP Forwarding
                echo "Activam IP Forwarding..."
                sudo sed -i '/^net.ipv4.ip_forward/d' /etc/sysctl.conf
                echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
                sudo sysctl -p
                echo "IP Forwarding a fost activat!"
                ;;
            2)
                # Deazactivare IP Forwarding
                echo "Dezactivam IP Forwarding..."
                sudo sed -i '/^net.ipv4.ip_forward/d' /etc/sysctl.conf
                echo "net.ipv4.ip_forward = 0" | sudo tee -a /etc/sysctl.conf
                sudo sysctl -p
                echo "IP Forwarding a fost dezactivat!"
                ;;
            3)
                # Setare utilizare memorie (vm.swappiness)
                echo "Introdu valoarea dorita pentru utilizarea memoriei (0-100):"
                read -r valoare
                if [[ $valoare =~ ^[0-9]+$ ]] && ((valoare >= 0 && valoare <= 100)); then
                    sudo sed -i '/^vm.swappiness/d' /etc/sysctl.conf
                    echo "vm.swappiness = $valoare" | sudo tee -a /etc/sysctl.conf
                    sudo sysctl -p
                    echo "vm.swappiness a fost setat la $valoare!"
                else
                    echo "Valoare invalida! Introdu un numar intre 0 si 100."
                fi
                ;;
            4)
                # Activare loguri kernel (debug)
                echo "Activam logurile detaliate de kernel..."
                sudo sed -i '/^kernel.printk/d' /etc/sysctl.conf
                echo "kernel.printk = 7 4 1 3" | sudo tee -a /etc/sysctl.conf
                sudo sysctl -p
                echo "Logurile detaliate de kernel au fost activate!"
                ;;
            5)
                # Dezactivare loguri kernel (debug)
                echo "Dezactivam logurile detaliate de kernel..."
                sudo sed -i '/^kernel.printk/d' /etc/sysctl.conf
                echo "kernel.printk = 4 4 1 7" | sudo tee -a /etc/sysctl.conf
                sudo sysctl -p
                echo "Logurile detaliate de kernel au fost dezactivate!"
                ;;
            6)
                echo "Iesire din configurare resurse..."
                break
                ;;
            *)
                echo "Optiune invalida!"
                ;;
        esac
    done
}

# Aceasta functie genereaza un top al proceselor care consuma cele mai multe resurse.
# Solicita utilizatorului sa introduca numarul de procese dorit pentru afisare, folosind un format valid, de exemplu:
#  - '-p=5' pentru primele 5 procese.
#  - '--processes=3' pentru primele 3 procese.
# Verifica validitatea optiunii introduse (folosind regex pentru formatele acceptate).
# Extrage numarul de procese ('n') specificat de utilizator.
# Afiseaza si salveaza in fisierul 'top_processes.log' o lista cu:
#  - PID-ul procesului;
#  - Numele procesului;
#  - Procentul de memorie utilizat (%MEM);
#  - Procentul de CPU utilizat (%CPU);
# Datele sunt sortate descrescator dupa utilizarea memoriei ('--sort=-%mem') si sunt afisate in terminal.
# In cazul unui input invalid, afiseaza un mesaj de eroare.
function top_procese() {
    echo -n "Introdu numarul de procese pentru top (exemplu: -p=5 sau --processes=3): "
    read -r opt

    # Se verifica daca optiunea este valida
    if [[ $opt =~ ^(-p=|--processes=)([0-9]+)$ ]]; then
        n=${BASH_REMATCH[2]}                 # Extragem numarul de procese
        log_top_procese="top_processes.log"  # Fisier separat pentru aceste tipuri de log-uri

        echo "=== Generam top $n procese care consuma cele mai multe resurse ==="
        
        # Salvam datele in fisier si le afisam pe ecran
        ps -eo pid,comm,%mem,%cpu --sort=-%mem | head -n $((n+1)) | tee "$log_top_procese"

        echo "Log-ul a fost salvat in $log_top_procese"
    else
        echo "Eroare! Optiunea nu este valida! Folositi -p=n sau --processes=n, unde n = cifra !"
    fi
}

# Controleaza modul in care scriptul functioneaza in functie de numarul de argumente primite.
# Verifica daca scriptul a fost apelat cu argumente:
#  - Daca exista argumente ('$# -gt 0'), se proceseaza ce se primeste de la tastatura (in functie de optiunile disponibile)
#  - Daca NU exista argumente ('$# -eq 0'), se se afiseaza meniul interactiv 'meniu_principal'.
if [[ "$#" -gt 0 ]]; then
    parse_arguments "$@"
else
    meniu_principal
fi
