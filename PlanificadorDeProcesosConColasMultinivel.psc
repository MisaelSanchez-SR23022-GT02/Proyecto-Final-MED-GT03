SubProceso EjecutarRoundRobin
    Definir totalProcesos, quantum, tiempoActual, terminados Como Entero
    Definir i, j, indiceActual, tiempoEjecucion Como Entero
    
    totalProcesos <- 3
    quantum <- 3
    
    // Arreglos paralelos para representar los atributos de cada proceso
    Dimension pid[3], at[3], bt[3], rem[3], ft[3], st[3], enCola[3]
    Definir pid Como Caracter
    Definir at, bt, rem, ft, st, enCola Como Entero
    
    // --- 1. CARGA DE DATOS ---
    // Proceso 1
    pid[1] <- "P1"
    at[1] <- 0
    bt[1] <- 5
    // Proceso 2
    pid[2] <- "P2"
    at[2] <- 1
    bt[2] <- 3
    // Proceso 3
    pid[3] <- "P3"
    at[3] <- 2
    bt[3] <- 2
    
    // --- 2. INICIALIZACION DE VARIABLES ---
    Para i <- 1 Hasta totalProcesos Hacer
        rem[i] <- bt[i]     
        st[i] <- -1         
        ft[i] <- 0          
        enCola[i] <- 0      
    FinPara
    
    // Simulacion de una Cola FIFO usando un arreglo
    Dimension colaRR[100]
    Definir frente, finCola Como Entero
    frente <- 1
    finCola <- 0
    
    tiempoActual <- 0
    terminados <- 0
    
    // --- 3. BUCLE PRINCIPAL DE SIMULACION ---
    Mientras terminados < totalProcesos Hacer
        
        // A. Encolar procesos que acaban de llegar en este 'tiempoActual'
        Para i <- 1 Hasta totalProcesos Hacer
            Si at[i] <= tiempoActual Y rem[i] > 0 Y enCola[i] == 0 Entonces
                finCola <- finCola + 1
                colaRR[finCola] <- i
                enCola[i] <- 1 // Marcamos que ya entró a la cola
            FinSi
        FinPara
        
        // B. Verificar si hay procesos listos para ejecutar
        Si frente > finCola Entonces
            // CPU ociosa, avanzamos el reloj
            tiempoActual <- tiempoActual + 1
        Sino
            // C. Extraer el primer proceso de la cola
            indiceActual <- colaRR[frente]
            frente <- frente + 1
            enCola[indiceActual] <- 0 // Lo sacamos de la cola
            
            // D. Si es su primera vez en CPU, guardar el tiempo de respuesta (RT)
            Si st[indiceActual] == -1 Entonces
                st[indiceActual] <- tiempoActual
            FinSi
            
            // E. Determinar cuánto tiempo va a usar la CPU en este turno
            Si rem[indiceActual] < quantum Entonces
                tiempoEjecucion <- rem[indiceActual]
            Sino
                tiempoEjecucion <- quantum
            FinSi
            
            // F. Simular la ejecución segundo a segundo
            Para j <- 1 Hasta tiempoEjecucion Hacer
                tiempoActual <- tiempoActual + 1
                rem[indiceActual] <- rem[indiceActual] - 1
                
                // ¡IMPORTANTE! Mientras corre, revisar si llegan procesos nuevos
                Para i <- 1 Hasta totalProcesos Hacer
                    Si at[i] == tiempoActual Y rem[i] > 0 Y enCola[i] == 0 Entonces
                        finCola <- finCola + 1
                        colaRR[finCola] <- i
                        enCola[i] <- 1
                    FinSi
                FinPara
            FinPara
            
            // G. Revisar qué pasó con el proceso al terminar su turno
            Si rem[indiceActual] == 0 Entonces
                // El proceso finalizó por completo
                ft[indiceActual] <- tiempoActual
                terminados <- terminados + 1
            Sino
                // Agotó su quantum pero no ha terminado: vuelve al final de la cola
                finCola <- finCola + 1
                colaRR[finCola] <- indiceActual
                enCola[indiceActual] <- 1
            FinSi
            
        FinSi
    FinMientras
    
    // --- 4. CALCULO E IMPRESION DE METRICAS ---
    Escribir ""
    Escribir "--- Resultados de la Simulacion Round Robin (q=", quantum, ") ---"
    Definir tat, wt, rt Como Entero
    Para i <- 1 Hasta totalProcesos Hacer
        tat <- ft[i] - at[i]
        wt <- tat - bt[i]
        rt <- st[i] - at[i]
        
        Escribir "Proceso: ", pid[i]
        Escribir "  Llegada (AT): ", at[i], " | Rafaga (BT): ", bt[i]
        Escribir "  Finalizacion (FT): ", ft[i]
        Escribir "  Retorno (TAT): ", tat
        Escribir "  Espera (WT): ", wt
        Escribir "  Respuesta (RT): ", rt
        Escribir "---------------------------------------"
    FinPara
    Escribir "Presione ENTER para continuar..."
    Esperar Tecla
FinSubProceso

SubProceso EjecutarPrioridades
    Definir totalProcesos, tiempoActual, terminados Como Entero
    Definir i, j, indiceActual, temp, k Como Entero
    Definir nuevoMayor, salirEjecucion, seguir Como Logico
    
    totalProcesos <- 3
    Dimension pid[4], at[4], bt[4], prio[4], rem[4], ft[4], st[4], enListo[4]
    Definir pid Como Caracter
    Definir at, bt, prio, rem, ft, st, enListo Como Entero
    
    pid[1] <- "P1"; at[1] <- 0; bt[1] <- 5; prio[1] <- 2
    pid[2] <- "P2"; at[2] <- 1; bt[2] <- 3; prio[2] <- 1
    pid[3] <- "P3"; at[3] <- 2; bt[3] <- 2; prio[3] <- 3
    
    Para i <- 1 Hasta totalProcesos Hacer
        rem[i] <- bt[i]
        st[i] <- -1
        ft[i] <- 0
        enListo[i] <- 0
    FinPara
    
    Dimension colaPrio[100]
    Definir tamCola Como Entero
    tamCola <- 0
    tiempoActual <- 0
    terminados <- 0
    
    Mientras terminados < totalProcesos Hacer
        
        // 1. Encolar procesos que ya llegaron
        Para i <- 1 Hasta totalProcesos Hacer
            Si at[i] <= tiempoActual Entonces
                Si rem[i] > 0 Entonces
                    Si enListo[i] == 0 Entonces
                        tamCola <- tamCola + 1
                        colaPrio[tamCola] <- i
                        enListo[i] <- 1
                        j <- tamCola
                        seguir <- Verdadero
                        Mientras seguir Hacer
                            Si j > 1 Entonces
                                Si prio[colaPrio[j]] < prio[colaPrio[j-1]] Entonces
                                    temp <- colaPrio[j]
                                    colaPrio[j] <- colaPrio[j-1]
                                    colaPrio[j-1] <- temp
                                    j <- j - 1
                                Sino
                                    seguir <- Falso
                                FinSi
                            Sino
                                seguir <- Falso
                            FinSi
                        FinMientras
                    FinSi
                FinSi
            FinSi
        FinPara
        
        // 2. CPU ociosa
        Si tamCola == 0 Entonces
            tiempoActual <- tiempoActual + 1
        Sino
            // 3. Tomar proceso de mayor prioridad
            indiceActual <- colaPrio[1]
            // Desplazar cola solo si hay mas de 1 elemento
            Si tamCola > 1 Entonces
                Para j <- 1 Hasta tamCola - 1 Hacer
                    colaPrio[j] <- colaPrio[j+1]
                FinPara
            FinSi
            tamCola <- tamCola - 1
            enListo[indiceActual] <- 0
            
            Si st[indiceActual] == -1 Entonces
                st[indiceActual] <- tiempoActual
            FinSi
            
            // 4. Ejecutar 1 unidad
            tiempoActual <- tiempoActual + 1
            rem[indiceActual] <- rem[indiceActual] - 1
            
            // 5. Encolar procesos que llegan ahora y detectar preemption
            nuevoMayor <- Falso
            Para i <- 1 Hasta totalProcesos Hacer
                Si at[i] == tiempoActual Entonces
                    Si rem[i] > 0 Entonces
                        Si enListo[i] == 0 Entonces
                            tamCola <- tamCola + 1
                            colaPrio[tamCola] <- i
                            enListo[i] <- 1
                            k <- tamCola
                            seguir <- Verdadero
                            Mientras seguir Hacer
                                Si k > 1 Entonces
                                    Si prio[colaPrio[k]] < prio[colaPrio[k-1]] Entonces
                                        temp <- colaPrio[k]
                                        colaPrio[k] <- colaPrio[k-1]
                                        colaPrio[k-1] <- temp
                                        k <- k - 1
                                    Sino
                                        seguir <- Falso
                                    FinSi
                                Sino
                                    seguir <- Falso
                                FinSi
                            FinMientras
                            Si prio[i] < prio[indiceActual] Entonces
                                nuevoMayor <- Verdadero
                            FinSi
                        FinSi
                    FinSi
                FinSi
            FinPara
            
            // 6. Verificar si termino
            Si rem[indiceActual] == 0 Entonces
                ft[indiceActual] <- tiempoActual
                terminados <- terminados + 1
            Sino
                // No termino: reencolar
                tamCola <- tamCola + 1
                colaPrio[tamCola] <- indiceActual
                enListo[indiceActual] <- 1
                k <- tamCola
                seguir <- Verdadero
                Mientras seguir Hacer
                    Si k > 1 Entonces
                        Si prio[colaPrio[k]] < prio[colaPrio[k-1]] Entonces
                            temp <- colaPrio[k]
                            colaPrio[k] <- colaPrio[k-1]
                            colaPrio[k-1] <- temp
                            k <- k - 1
                        Sino
                            seguir <- Falso
                        FinSi
                    Sino
                        seguir <- Falso
                    FinSi
                FinMientras
            FinSi
        FinSi
    FinMientras
    
    // Mostrar resultados
    Escribir ""
    Escribir "--- Resultados de Prioridades Apropiativo ---"
    Definir tat, wt, rt Como Entero
    Para i <- 1 Hasta totalProcesos Hacer
        tat <- ft[i] - at[i]
        wt <- tat - bt[i]
        rt <- st[i] - at[i]
        Escribir "Proceso: ", pid[i], "  AT:", at[i], "  BT:", bt[i], "  FT:", ft[i], "  TAT:", tat, "  WT:", wt, "  RT:", rt
    FinPara
    Escribir "Presione ENTER para continuar..."
    Esperar Tecla
FinSubProceso

SubProceso EjecutarMLFQ
    Definir totalProcesos, tiempoActual, terminados, tiempoBoost, nivelActual Como Entero
    Definir i, j, indiceActual, unidadesEjec, quantumActual, proc, temp Como Entero
    Definir ejecutando Como Logico
    
    totalProcesos <- 3
    Dimension pid[3], at[3], bt[3], rem[3], ft[3], st[3], nivel[3], enCola[3]
    Definir pid Como Caracter
    Definir at, bt, rem, ft, st, nivel, enCola Como Entero
    
    pid[1] <- "P1"; at[1] <- 0; bt[1] <- 5
    pid[2] <- "P2"; at[2] <- 1; bt[2] <- 3
    pid[3] <- "P3"; at[3] <- 2; bt[3] <- 2
    
    Dimension cola0[100], cola1[100], cola2[100]
    Definir f0, f1, f2, fin0, fin1, fin2 Como Entero
    f0 <- 1; fin0 <- 0
    f1 <- 1; fin1 <- 0
    f2 <- 1; fin2 <- 0
    
    // Quantums por nivel (indices 1, 2, 3)
    Dimension quantumNivel[3]
    quantumNivel[1] <- 2
    quantumNivel[2] <- 4
    quantumNivel[3] <- 999
    
    Para i <- 1 Hasta totalProcesos Hacer
        rem[i] <- bt[i]
        st[i] <- -1
        ft[i] <- 0
        nivel[i] <- 1   // nivel inicial es 1 (cola mas prioritaria)
        enCola[i] <- 0
    FinPara
    
    tiempoActual <- 0
    terminados <- 0
    tiempoBoost <- 10
    
    Mientras terminados < totalProcesos Hacer
        // Boost periodico: cada tiempoBoost unidades mover todo a cola0
        Si tiempoActual > 0 Y (tiempoActual MOD tiempoBoost) == 0 Entonces
            Para i <- f1 Hasta fin1 Hacer
                fin0 <- fin0 + 1
                cola0[fin0] <- cola1[i]
                nivel[cola1[i]] <- 1
                enCola[cola1[i]] <- 1
            FinPara
            Para i <- f2 Hasta fin2 Hacer
                fin0 <- fin0 + 1
                cola0[fin0] <- cola2[i]
                nivel[cola2[i]] <- 1
                enCola[cola2[i]] <- 1
            FinPara
            f1 <- 1; fin1 <- 0
            f2 <- 1; fin2 <- 0
        FinSi
        
        // Encolar nuevos procesos que han llegado
        Para i <- 1 Hasta totalProcesos Hacer
            Si at[i] <= tiempoActual Y rem[i] > 0 Y enCola[i] == 0 Entonces
                fin0 <- fin0 + 1
                cola0[fin0] <- i
                enCola[i] <- 1
                nivel[i] <- 1
            FinSi
        FinPara
        
        // Elegir cola con mayor prioridad disponible
        Si f0 <= fin0 Entonces
            nivelActual <- 1
        Sino
            Si f1 <= fin1 Entonces
                nivelActual <- 2
            Sino
                Si f2 <= fin2 Entonces
                    nivelActual <- 3
                Sino
                    nivelActual <- -1
                FinSi
            FinSi
        FinSi
        
        Si nivelActual == -1 Entonces
            // CPU ociosa, avanzar tiempo
            tiempoActual <- tiempoActual + 1
        Sino
            // Sacar proceso de la cola correspondiente
            Si nivelActual == 1 Entonces
                indiceActual <- cola0[f0]
                f0 <- f0 + 1
            FinSi
            Si nivelActual == 2 Entonces
                indiceActual <- cola1[f1]
                f1 <- f1 + 1
            FinSi
            Si nivelActual == 3 Entonces
                indiceActual <- cola2[f2]
                f2 <- f2 + 1
            FinSi
            enCola[indiceActual] <- 0
            
            Si st[indiceActual] == -1 Entonces
                st[indiceActual] <- tiempoActual
            FinSi
            
            quantumActual <- quantumNivel[nivel[indiceActual]]
            
            Si quantumActual == 999 Entonces
                unidadesEjec <- rem[indiceActual]
            Sino
                Si rem[indiceActual] < quantumActual Entonces
                    unidadesEjec <- rem[indiceActual]
                Sino
                    unidadesEjec <- quantumActual
                FinSi
            FinSi
            
            // Ejecutar unidadesEjec unidades usando Mientras para poder salir antes
            j <- 0
            Mientras j < unidadesEjec Y rem[indiceActual] > 0 Hacer
                j <- j + 1
                tiempoActual <- tiempoActual + 1
                rem[indiceActual] <- rem[indiceActual] - 1
                
                // Encolar procesos que llegan durante la ejecucion
                Para i <- 1 Hasta totalProcesos Hacer
                    Si at[i] == tiempoActual Y rem[i] > 0 Y enCola[i] == 0 Entonces
                        fin0 <- fin0 + 1
                        cola0[fin0] <- i
                        enCola[i] <- 1
                        nivel[i] <- 1
                    FinSi
                FinPara
                
                Si rem[indiceActual] == 0 Entonces
                    ft[indiceActual] <- tiempoActual
                    terminados <- terminados + 1
                    j <- unidadesEjec  // forzar salida del Mientras
                FinSi
            FinMientras
            
            // Si no termino, bajar de nivel si agoto el quantum completo
            Si rem[indiceActual] > 0 Entonces
                Si unidadesEjec == quantumActual Y quantumActual <> 999 Entonces
                    nivel[indiceActual] <- nivel[indiceActual] + 1
                    Si nivel[indiceActual] > 3 Entonces
                        nivel[indiceActual] <- 3
                    FinSi
                FinSi
                // Reencolar en la cola de su nuevo nivel
                Si nivel[indiceActual] == 1 Entonces
                    fin0 <- fin0 + 1
                    cola0[fin0] <- indiceActual
                FinSi
                Si nivel[indiceActual] == 2 Entonces
                    fin1 <- fin1 + 1
                    cola1[fin1] <- indiceActual
                FinSi
                Si nivel[indiceActual] == 3 Entonces
                    fin2 <- fin2 + 1
                    cola2[fin2] <- indiceActual
                FinSi
                enCola[indiceActual] <- 1
            FinSi
        FinSi
    FinMientras
    
    // Mostrar resultados
    Escribir ""
    Escribir "--- Resultados de MLFQ (q0=2, q1=4, q2=inf, boost=10) ---"
    Definir tat, wt, rt Como Entero
    Para i <- 1 Hasta totalProcesos Hacer
        tat <- ft[i] - at[i]
        wt <- tat - bt[i]
        rt <- st[i] - at[i]
        Escribir "Proceso: ", pid[i], "  AT:", at[i], "  BT:", bt[i], "  FT:", ft[i], "  TAT:", tat, "  WT:", wt, "  RT:", rt
    FinPara
    Escribir "Presione ENTER para continuar..."
    Esperar Tecla
FinSubProceso

Algoritmo PlanificadorDeProcesosConColasMultinivel
    Definir opcionUsuario Como Entero
    
    Repetir
        Borrar Pantalla
        Escribir "============================================="
        Escribir "    SIMULADOR DE ALGORITMOS DE PLANIFICACIÓN "
        Escribir "============================================="
        Escribir "1. Simular Round Robin (RR)"
        Escribir "2. Simular Prioridades (Apropiativo)"
        Escribir "3. Simular Colas Multinivel (MLFQ)"
        Escribir "4. Salir"
        Escribir "============================================="
        Escribir "Seleccione una opción (1-4): " Sin Saltar
        Leer opcionUsuario
        
		Segun opcionUsuario Hacer
            1:
                Borrar Pantalla
                EjecutarRoundRobin
            2:
                Borrar Pantalla
                EjecutarPrioridades
            3:
                Borrar Pantalla
                EjecutarMLFQ
            4:
                Borrar Pantalla
                Escribir "Saliendo del simulador... ¡Hasta pronto!"
            De Otro Modo:
                Escribir "Opción inválida. Presione ENTER e intente de nuevo."
                Esperar Tecla
        FinSegun
        
    Mientras Que opcionUsuario <> 4
    
FinAlgoritmo