Algoritmo ArbolBPlus
    // ORDEN t = 2 => cada nodo puede tener entre 1 y 3 claves (excepto nodo_raiz)
    // Máximo 3 claves por nodo (2t-1), máximo 4 hijos (2t)
    Definir MAX_NODOS Como Entero
    MAX_NODOS <- 50
    
    // Estructuras paralelas
    Definir tipo, numC, claves, hijos, sigHoja Como Entero
    Dimension tipo[MAX_NODOS]        // 0=hoja, 1=interno
    Dimension numC[MAX_NODOS]        // cantidad de claves actual
    Dimension claves[MAX_NODOS, 3]   // hasta 3 claves por nodo (índices 1..3)
    Dimension hijos[MAX_NODOS, 4]    // hasta 4 hijos (índices 1..4)
    Dimension sigHoja[MAX_NODOS]     // siguiente hoja (0 significa fin de la lista)
    
    // Inicializar todas las estructuras en Base 1
    Definir i, j Como Entero
    Para i <- 1 Hasta MAX_NODOS Con Paso 1 Hacer
        tipo[i] <- 0
        numC[i] <- 0
        sigHoja[i] <- 0 // 0 es el nuevo nulo
        Para j <- 1 Hasta 3 Con Paso 1 Hacer
            claves[i, j] <- -1
        FinPara
        Para j <- 1 Hasta 4 Con Paso 1 Hacer
            hijos[i, j] <- 0
        FinPara
    FinPara
    
    // Crear nodo_raiz (hoja vacía)
    Definir nodo_raiz, totalNodos Como Entero
    totalNodos <- 1
    nodo_raiz <- totalNodos
    tipo[nodo_raiz] <- 0
    numC[nodo_raiz] <- 0
    
    // Menú interactivo
    Definir opcion, valor, encontrado Como Entero
    Definir salir Como Logico
    salir <- Falso
    
    Mientras No salir Hacer
        Escribir "======== ÁRBOL B+ (BASE 1) ========"
        Escribir "1. Insertar clave"
        Escribir "2. Buscar clave"
        Escribir "3. Mostrar hojas en orden"
        Escribir "4. Salir"
        Escribir "Opción: " Sin Saltar
        Leer opcion
        
        Segun opcion Hacer
            1:
                Escribir "Clave a insertar (entero): " Sin Saltar
                Leer valor
                Insertar(valor, nodo_raiz, totalNodos, tipo, numC, claves, hijos, sigHoja)
                Escribir "------------------------"
            2:
                Escribir "Clave a buscar: " Sin Saltar
                Leer valor
                encontrado <- Buscar(nodo_raiz, valor, tipo, numC, claves, hijos)
                Si encontrado = 1 Entonces
                    Escribir ">> Clave ", valor, " ENCONTRADA en el árbol."
                Sino
                    Escribir ">> Clave ", valor, " NO encontrada."
                FinSi
                Escribir "------------------------"
            3:
                MostrarHojas(nodo_raiz, tipo, hijos, numC, claves, sigHoja)
                Escribir "------------------------"
            4:
                salir <- Verdadero
                Escribir "Saliendo..."
            De Otro Modo:
                Escribir "Opción inválida"
        FinSegun
    FinMientras
FinAlgoritmo

// =============== IMPLEMENTACIÓN DE OPERACIONES ===============

SubProceso Insertar(clave Por Referencia, nodo_raiz Por Referencia, totalNodos Por Referencia, tipo, numC, claves, hijos, sigHoja)
    Definir nuevaRaiz Como Entero
    
    // Si la nodo_raiz está llena (3 claves), se divide y crece hacia arriba
    Si numC[nodo_raiz] = 3 Entonces
        totalNodos <- totalNodos + 1
        nuevaRaiz <- totalNodos
        tipo[nuevaRaiz] <- 1   // nodo interno
        numC[nuevaRaiz] <- 0
        hijos[nuevaRaiz, 1] <- nodo_raiz // Primer hijo en índice 1
        DividirHijo(nuevaRaiz, 1, totalNodos, tipo, numC, claves, hijos, sigHoja)
        nodo_raiz <- nuevaRaiz
    FinSi
    InsertarNoLleno(nodo_raiz, clave, totalNodos, tipo, numC, claves, hijos, sigHoja)
FinSubProceso


SubProceso InsertarNoLleno(nodo, clave Por Referencia, totalNodos Por Referencia, tipo, numC, claves, hijos, sigHoja)
    Definir i, nuevoHijo Como Entero
    
    Si tipo[nodo] = 0 Entonces
        // Nodo hoja: insertar ordenadamente (Base 1)
        i <- numC[nodo]
        Mientras i >= 1 Y clave < claves[nodo, i] Hacer
            claves[nodo, i+1] <- claves[nodo, i]
            i <- i - 1
        FinMientras
        claves[nodo, i+1] <- clave
        numC[nodo] <- numC[nodo] + 1
        Escribir "Clave ", clave, " insertada en hoja ID=", nodo
    Sino
        // Nodo interno: buscar por qué hijo descender
        i <- 1
        Mientras i <= numC[nodo] Y clave >= claves[nodo, i] Hacer
            i <- i + 1
        FinMientras
        nuevoHijo <- hijos[nodo, i]
        
        // Si ese hijo está lleno, lo dividimos primero
        Si numC[nuevoHijo] = 3 Entonces
            DividirHijo(nodo, i, totalNodos, tipo, numC, claves, hijos, sigHoja)
            Si clave >= claves[nodo, i] Entonces
                i <- i + 1
                nuevoHijo <- hijos[nodo, i]
            FinSi
        FinSi
        InsertarNoLleno(nuevoHijo, clave, totalNodos, tipo, numC, claves, hijos, sigHoja)
    FinSi
FinSubProceso


SubProceso DividirHijo(padre, indiceHijo, totalNodos Por Referencia, tipo, numC, claves, hijos, sigHoja)
    Definir hijo, nuevo, mitad, i, k, clavePromovida Como Entero
    hijo <- hijos[padre, indiceHijo]
    
    totalNodos <- totalNodos + 1
    nuevo <- totalNodos
    
    tipo[nuevo] <- tipo[hijo]
    numC[nuevo] <- 0
    mitad <- 2   // En base 1 con 3 claves, la del medio es la posición 2
    
    // Copiar elementos al nuevo nodo derecho
    Si tipo[hijo] = 0 Entonces
        // Si es hoja, la clave del medio REMANECE en la hoja derecha
        Para i <- mitad Hasta 3 Hacer
            numC[nuevo] <- numC[nuevo] + 1
            claves[nuevo, numC[nuevo]] <- claves[hijo, i]
        FinPara
    Sino
        // Si es interno, la clave del medio sube y NO se duplica abajo
        Para i <- mitad+1 Hasta 3 Hacer
            numC[nuevo] <- numC[nuevo] + 1
            claves[nuevo, numC[nuevo]] <- claves[hijo, i]
        FinPara
    FinSi
    
    // Si es interno, redistribuir también sus hijos correspondientes
    Si tipo[hijo] = 1 Entonces
        k <- 1
        Para i <- mitad+1 Hasta 4 Hacer
            hijos[nuevo, k] <- hijos[hijo, i]
            k <- k + 1
        FinPara
    FinSi
    
    // Reducir el tamaño del hijo izquierdo original
    numC[hijo] <- mitad - 1
    
    // Ajustar punteros de la secuencia de hojas
    Si tipo[hijo] = 0 Entonces
        sigHoja[nuevo] <- sigHoja[hijo]
        sigHoja[hijo] <- nuevo
    FinSi
    
    // La clave que sube al padre
    clavePromovida <- claves[hijo, mitad]
    
    // Desplazar espacio en el padre para meter la clave promovida y el nuevo hijo
    i <- numC[padre]
    Mientras i >= indiceHijo Hacer
        claves[padre, i+1] <- claves[padre, i]
        hijos[padre, i+2] <- hijos[padre, i+1]
        i <- i - 1
    FinMientras
    
    claves[padre, indiceHijo] <- clavePromovida
    hijos[padre, indiceHijo+1] <- nuevo
    numC[padre] <- numC[padre] + 1
    
    Escribir ">> DIVISIÓN: Nodo ", hijo, " dividido. Clave promovida: ", clavePromovida
FinSubProceso

Funcion encontrado <- Buscar(nodo_raiz, clave, tipo, numC, claves, hijos)
    Definir nodo, i Como Entero
    encontrado <- 0
    nodo <- nodo_raiz
    
    // Descender por las ramas internas
    Mientras tipo[nodo] = 1 Hacer
        i <- 1
        Mientras i <= numC[nodo] Y clave >= claves[nodo, i] Hacer
            i <- i + 1
        FinMientras
        nodo <- hijos[nodo, i]
    FinMientras
    
    // Buscar la coincidencia exacta en la hoja
    i <- 1
    Mientras i <= numC[nodo] Y claves[nodo, i] <> clave Hacer
        i <- i + 1
    FinMientras
    
    Si i <= numC[nodo] Entonces
        encontrado <- 1
    FinSi
FinFuncion

SubProceso MostrarHojas(nodo_raiz, tipo, hijos, numC, claves, sigHoja)
    Definir nodo, i Como Entero
    nodo <- nodo_raiz
    
    // Viajar hasta la hoja del extremo izquierdo (Hijo 1)
    Mientras tipo[nodo] = 1 Hacer
        nodo <- hijos[nodo, 1]
    FinMientras
    
    // Recorrido secuencial a través de sigHoja
    Escribir "Claves en orden ascendente: " Sin Saltar
    Mientras nodo <> 0 Hacer // Terminamos cuando el puntero sea 0
        Para i <- 1 Hasta numC[nodo] Con Paso 1 Hacer
            Escribir Sin Saltar claves[nodo, i], " "
        FinPara
        nodo <- sigHoja[nodo]
    FinMientras
    Escribir ""
FinSubProceso
